import os
import unittest

from fastapi.testclient import TestClient
import pandas as pd

os.environ["CHAT_ENABLED"] = "false"

from app import app
from core.auth import require_user
from core.catalog_sampling import CATEGORIES, CatalogSampler


class SmallEngine:
    def __init__(self):
        self.df = pd.DataFrame([
            (1, "buy", "Residential - Buy", "Apartment"),
            (2, "buy", "Residential - Buy", "Villa"),
            (3, "commercial_buy", "Commercial - Buy", "Villa"),
            (4, "rent", "Residential - Buy", "Apartment"),
            (5, "buy", "Residential - Buy", "Apartment"),
            (5, "rent", "Residential - Rent", "Apartment"),
            (6, "commercial_buy", "Commercial - Buy", "Office Space"),
            (7, "buy", "Residential - Buy", "Land"),
        ], columns=["id", "category", "category_en", "property_type"])

    def get_property(self, pid):
        return pid


class CatalogSamplingTests(unittest.TestCase):
    def test_filters_before_sampling_and_excludes_ambiguous_or_duplicate_rows(self):
        sampler = CatalogSampler(SmallEngine())
        self.assertEqual(set(sampler.sample("buy", 45, [])), {1, 2})
        self.assertEqual(sampler.sample("commercial_buy", 45, []), [6])
        self.assertEqual(sampler.sample("rent", 45, []), [])

    def test_refresh_prefers_unseen_and_fills_when_supply_is_short(self):
        sampler = CatalogSampler(SmallEngine())
        self.assertEqual(sampler.sample("buy", 1, [1]), [2])
        self.assertEqual(sampler.sample("buy", 15, [1]), [2, 1])

    def test_authenticated_route_returns_bounded_unique_samples_for_real_catalog(self):
        client = TestClient(app)
        path = "/api/recommendations/catalog/sample"
        self.assertEqual(client.post(path, json={"category": "buy", "limit": 15}).status_code, 401)
        app.dependency_overrides[require_user] = lambda: {"uid": "unit-test-user"}
        self.addCleanup(app.dependency_overrides.pop, require_user)
        self.assertEqual(client.post(path, json={"category": "all", "limit": 45}).status_code, 422)
        self.assertEqual(client.post(path, json={"category": "buy", "limit": 46}).status_code, 422)
        for category, (label, allowed_types) in CATEGORIES.items():
            with self.subTest(category=category):
                first = client.post(path, json={"category": category, "limit": 45})
                self.assertEqual(first.status_code, 200)
                rows = first.json()
                ids = {item["id"] for item in rows}
                self.assertEqual(len(rows), 45)
                self.assertEqual(len(ids), 45)
                self.assertTrue(all(row["category"] == category and row["category_en"] == label
                                    and row["property_type"] in allowed_types for row in rows))
                refreshed = client.post(path, json={"category": category, "limit": 15,
                                                     "exclude_ids": list(ids)})
                self.assertEqual(refreshed.status_code, 200)
                updated = {item["id"] for item in refreshed.json()}
                self.assertEqual(len(updated), 15)
                self.assertFalse(ids & updated)

