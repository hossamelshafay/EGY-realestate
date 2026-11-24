"""Offline inference contract; uses saved fitted pipelines without refitting."""
from __future__ import annotations

import math
import re

import numpy as np
import pandas as pd

FEATURES = ["size", "bedrooms", "bathrooms", "latitude", "longitude",
            "property_type", "category"]


def parse_size(value):
    """Accept a positive area or ordered range; never invent an area."""
    if isinstance(value, bool):
        raise ValueError("size must be a number or an ordered range")
    if isinstance(value, str):
        match = re.fullmatch(r"\s*(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*", value)
        if match:
            low, high = map(float, match.groups())
            if not 20 <= low <= high <= 10000:
                raise ValueError("size range must be ordered and within 20..10000 m²")
            return (low + high) / 2
    try:
        area = float(value)
    except (ValueError, TypeError):
        raise ValueError("size must be a number or an ordered range") from None
    if not math.isfinite(area) or not 20 <= area <= 10000:
        raise ValueError("size must be finite and within 20..10000 m²")
    return area


def model_contract(model):
    """Read feature order and fitted categorical vocabularies from the artifact."""
    if list(getattr(model, "feature_names_in_", [])) != FEATURES:
        raise ValueError("Saved model does not have the required seven features")
    vocabularies = []
    for estimator in getattr(model, "estimators_", []):
        preprocessor = estimator.named_steps["preprocessor"]
        if list(preprocessor.feature_names_in_) != FEATURES:
            raise ValueError("Base estimator feature order differs")
        encoder = preprocessor.named_transformers_["cat"]
        from sklearn.preprocessing import OrdinalEncoder, StandardScaler
        if not isinstance(preprocessor.named_transformers_["num"], StandardScaler):
            raise ValueError("Expected fitted StandardScaler for numeric features")
        if not isinstance(encoder, OrdinalEncoder):
            raise ValueError("Expected fitted OrdinalEncoder for categorical features")
        groups = {name: list(columns) for name, _, columns in preprocessor.transformers_}
        if groups.get("num") != FEATURES[:5] or groups.get("cat") != FEATURES[-2:]:
            raise ValueError("Saved preprocessing feature groups differ from contract")
        vocabulary = {
            name: [str(value) for value in values]
            for name, values in zip(FEATURES[-2:], encoder.categories_)
        }
        if len(vocabulary) != 2 or any(not values for values in vocabulary.values()):
            raise ValueError("Missing fitted categorical vocabularies")
        vocabularies.append(vocabulary)
    if not vocabularies or any(v != vocabularies[0] for v in vocabularies):
        raise ValueError("Fitted categorical vocabularies unavailable or inconsistent")
    return {"features": FEATURES, "categories": vocabularies[0]}


def predict_price(model, values):
    """Predict log1p(price), invert with expm1, and reject invalid outputs."""
    contract = model_contract(model)
    row = {name: values[name] for name in FEATURES}
    row["size"] = parse_size(row["size"])
    for name in FEATURES[:5]:
        if isinstance(row[name], bool) or not math.isfinite(float(row[name])):
            raise ValueError(f"{name} must be finite numeric input")
    for name, low, high in [("bedrooms", 0, 20), ("bathrooms", 0, 20),
                            ("latitude", 22, 32), ("longitude", 24, 38)]:
        if not low <= float(row[name]) <= high:
            raise ValueError(f"{name} must be within {low}..{high}")
    for name, allowed in contract["categories"].items():
        if row[name] not in allowed:
            raise ValueError(f"Unsupported {name}; use /api/predict/options")
    frame = pd.DataFrame([row], columns=FEATURES)
    log_price = float(model.predict(frame)[0])
    with np.errstate(over="raise", invalid="raise"):
        price = float(np.expm1(log_price))
    if not math.isfinite(price) or price <= 0:
        raise RuntimeError("Model returned an invalid price")
    return log_price, price
