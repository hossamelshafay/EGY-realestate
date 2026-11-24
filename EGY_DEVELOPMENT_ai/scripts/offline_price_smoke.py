r"""Load the real saved artifact and print an offline inference record.

Run from backend root: .venv\Scripts\python.exe scripts\offline_price_smoke.py
No training, provider client, Firebase access or external API calls.
"""
import hashlib
import importlib.metadata
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from core.price_prediction import model_contract, predict_price
from core.startup import load_price_model

model = load_price_model()
values = dict(size=130, bedrooms=3, bathrooms=2, latitude=30.03,
              longitude=31.47, property_type="Apartment", category="buy")
log_price, price = predict_price(model, values)
preprocessing = []
for estimator in model.estimators_:
    processor = estimator.named_steps["preprocessor"]
    scaler = processor.named_transformers_["num"]
    encoder = processor.named_transformers_["cat"]
    preprocessing.append({
        "scaler": type(scaler).__name__,
        "mean": scaler.mean_.tolist(), "scale": scaler.scale_.tolist(),
        "encoder": type(encoder).__name__,
        "handle_unknown": encoder.handle_unknown,
        "unknown_value": int(encoder.unknown_value),
    })
artifact = ROOT / "models/regression/final_price_prediction_model.joblib"
print(json.dumps({
    "python": sys.version,
    "versions": {p: importlib.metadata.version(p) for p in
                 ["scikit-learn", "numpy", "pandas", "xgboost", "joblib"]},
    "artifact_sha256": hashlib.sha256(artifact.read_bytes()).hexdigest(),
    "model_type": type(model).__name__, "contract": model_contract(model),
    "preprocessing": preprocessing, "input": values,
    "log_prediction": log_price, "raw_price_egp": price,
}, indent=2))
