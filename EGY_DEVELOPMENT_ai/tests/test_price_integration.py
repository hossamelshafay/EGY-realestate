"""Real artifact tests. Run from backend root: python -m unittest discover -s tests -v.

No provider API calls. Firebase network verification is mocked ONLY in tests.
"""
import json
import os
import unittest
from unittest.mock import patch

os.environ["CHAT_ENABLED"] = "false"

from fastapi import HTTPException
from fastapi.testclient import TestClient
from starlette.requests import Request

from app import app
from core.auth import require_user
from core.price_prediction import FEATURES, model_contract, predict_price
from core.startup import load_price_model
from schemas import PredictRequest


class PriceIntegrationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.model = load_price_model()  # The real checked-in artifact, never a fake model.
        cls.values = dict(size=130, bedrooms=3, bathrooms=2,
                          latitude=30.03, longitude=31.47,
                          property_type="Apartment", category="buy")

    def test_actual_offline_prediction(self):
        contract = model_contract(self.model)
        self.assertEqual(contract["features"], FEATURES)
        log_price, raw_price = predict_price(self.model, self.values)
        self.assertGreater(raw_price, 0)
        print(json.dumps({"input": self.values, "contract": contract,
                          "log_prediction": log_price, "raw_price_egp": raw_price}))

    def test_bad_inputs_are_rejected(self):
        for value in ["nonsense", "150-100", "-50", "100-200-300", 0, 10001,
                      True, float("nan"), float("inf")]:
            with self.subTest(size=value), self.assertRaises(ValueError):
                PredictRequest(**(self.values | {"size": value}))
        for field in FEATURES[:5]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                PredictRequest(**(self.values | {field: True}))
        with self.assertRaises(ValueError):
            predict_price(self.model, self.values | {"property_type": "unknown"})
        with self.assertRaises(ValueError):
            predict_price(self.model, self.values | {"category": "unknown"})
        self.assertEqual(PredictRequest(**(self.values | {"size": "100-150"})).size, 125)

    def test_startup_and_real_endpoint_without_llm_credentials(self):
        # Test-only auth override; this is not a test of real Firebase credentials.
        app.dependency_overrides[require_user] = lambda: {"uid": "offline-test"}
        try:
            with TestClient(app) as client:
                self.assertIsNone(app.state.llm_client)
                self.assertTrue(client.get("/api/health").json()["model_loaded"])
                self.assertEqual(client.get("/api/predict/options").status_code, 200)
                response = client.post("/api/predict", json=self.values)
                self.assertEqual(response.status_code, 200, response.text)
                result = response.json()
                self.assertIsNone(result["confidence_pct"])
                self.assertEqual(result["shap_breakdown"], [])
                self.assertEqual(result["feature_importance"], [])
                self.assertEqual(result["range_method"], "heuristic_plus_minus_8_percent_rounded")
                self.assertEqual(client.post("/api/chat", json={"message": "hello"}).status_code, 503)
                self.assertEqual(client.post("/api/predict", json=self.values | {"size": "bad"}).status_code, 422)
                self.assertEqual(client.post("/api/predict", json=self.values | {"category": "bad"}).status_code, 422)
                print(json.dumps({"endpoint_result": result}))
        finally:
            app.dependency_overrides.clear()

    def test_protected_routers_reject_missing_or_malformed_tokens(self):
        with TestClient(app) as client:
            for url, body in [("/api/predict", self.values), ("/api/chat", {"message": "hi"}),
                              ("/api/recommendations/search", {})]:
                self.assertEqual(client.post(url, json=body).status_code, 401)
            self.assertEqual(client.get("/api/predict/options").status_code, 401)


class FirebaseVerificationTest(unittest.TestCase):
    def request(self):
        return Request({"type": "http", "headers": [(b"authorization", b"Bearer test-only")]})

    def test_calls_admin_verification_with_revocation_check(self):
        with patch("core.auth._admin_app", return_value="test-app"), patch(
            "firebase_admin.auth.verify_id_token", return_value={"uid": "user-1"}
        ) as verify:
            request = self.request()
            self.assertEqual(require_user(request)["uid"], "user-1")
            verify.assert_called_once_with("test-only", app="test-app", check_revoked=True)

    def test_rejects_invalid_token_and_fails_closed_on_verifier_outage(self):
        from firebase_admin import auth
        for error, status in [(auth.InvalidIdTokenError("invalid"), 401),
                              (RuntimeError("unavailable"), 503)]:
            with patch("core.auth._admin_app", return_value="test-app"), patch(
                "firebase_admin.auth.verify_id_token", side_effect=error
            ), self.assertRaises(HTTPException) as caught:
                require_user(self.request())
            self.assertEqual(caught.exception.status_code, status)


if __name__ == "__main__":
    unittest.main()
