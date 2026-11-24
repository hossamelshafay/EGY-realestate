"""Price inference, independent of recommendation data and LLM providers."""
from __future__ import annotations

import logging

import anyio
from fastapi import APIRouter, HTTPException, Request

from core.price_prediction import model_contract, predict_price
from schemas import PredictRequest, PredictResponse

router = APIRouter(prefix="/api", tags=["Predict"])
logger = logging.getLogger(__name__)


def _model(request):
    model = getattr(request.app.state, "model", None)
    if model is None:
        raise HTTPException(503, "Price prediction model is unavailable")
    return model


@router.get("/predict/options")
def options(request: Request):
    """Return vocabularies of the actual loaded model, without guesses."""
    return model_contract(_model(request))


@router.post("/predict", response_model=PredictResponse,
             summary="Predict price using the saved regression model")
async def predict(req: PredictRequest, request: Request) -> PredictResponse:
    model = _model(request)
    try:
        _, raw_price = await anyio.to_thread.run_sync(
            lambda: predict_price(model, req.model_dump()))
    except ValueError as exc:
        raise HTTPException(422, str(exc)) from None
    except Exception:
        logger.exception("Price inference failed")
        raise HTTPException(503, "Price inference is unavailable") from None

    is_rent = "rent" in req.category
    step = 500.0 if is_rent else 25000.0
    price = float(round(raw_price / step) * step)
    if price <= 0:
        raise HTTPException(503, "Prediction is below the supported rounding resolution")
    return PredictResponse(
        predicted_price=price,
        raw_predicted_price=raw_price,
        range_low=float(round(price * 0.92 / step) * step),
        range_high=float(round(price * 1.08 / step) * step),
        range_method="heuristic_plus_minus_8_percent_rounded",
        currency="EGP/month" if is_rent else "EGP",
        meter_price=float(round(price / req.size)),
    )
