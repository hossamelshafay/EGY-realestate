"""
schemas.py — Pydantic request/response models for the Egyptian Real Estate AI Platform.

All API contracts live here so that api/chat.py, api/predict.py, and tests share
a single source of truth for data shapes. Changing a field means changing it once.
"""
from __future__ import annotations

from typing import List, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, field_validator


# ---------------------------------------------------------------------------
# Shared sub-model
# ---------------------------------------------------------------------------

class PropertyResult(BaseModel):
    """
    One property listing returned by the chatbot's search_properties tool.
    Field names match _row_to_compact() in src/chatbot/tools.py exactly.
    """
    id: int
    title: str
    price: Optional[float] = None
    price_label: str                   # "EGP" (buy) or "EGP / month" (rent)
    property_type: str
    category: str                      # "buy" | "rent" | "commercial_buy" | "commercial_rent"
    location: str
    bedrooms: Optional[float] = None   # null for commercial types that have none
    bathrooms: Optional[float] = None
    size: Optional[float] = None       # m²
    image_url: Optional[str] = None
    share_url: Optional[str] = None


# ---------------------------------------------------------------------------
# Chat
# ---------------------------------------------------------------------------

class ChatRequest(BaseModel):
    message: str = Field(
        ...,
        min_length=1,
        max_length=4000,
        description="The user's message or question.",
    )
    session_id: Optional[str] = Field(
        None,
        description=(
            "Existing session UUID. Omit (or pass null) on the first message "
            "of a new conversation; the server will create a session and return "
            "the new session_id in the response."
        ),
    )


class ChatResponse(BaseModel):
    reply: str = Field(description="The assistant's text reply.")
    session_id: str = Field(description="Session UUID — persist this in sessionStorage.")
    properties: List[PropertyResult] = Field(
        default_factory=list,
        description="Property cards to render (from the last search_properties tool call).",
    )
    suggestions: List[str] = Field(
        default_factory=list,
        description="Next-question suggestions for the prompt buttons.",
    )
    total_matches: Optional[int] = Field(
        None,
        description="Total matching properties count in catalog.",
    )
    applied_filters: Optional[dict] = Field(
        default_factory=dict,
        description="Filters applied in the search.",
    )


# ---------------------------------------------------------------------------
# Price prediction
# ---------------------------------------------------------------------------

class PredictRequest(BaseModel):
    """Seven required model features; no inferred coordinates or room counts."""
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)
    category: str = Field(min_length=1, max_length=80)
    property_type: str = Field(min_length=1, max_length=100)
    size: float = Field(ge=20, le=10000)
    bedrooms: float = Field(ge=0, le=20)
    bathrooms: float = Field(ge=0, le=20)
    latitude: float = Field(ge=22, le=32)
    longitude: float = Field(ge=24, le=38)

    @field_validator("size", mode="before")
    @classmethod
    def validate_size(cls, value):
        from core.price_prediction import parse_size
        return parse_size(value)

    @field_validator("bedrooms", "bathrooms", "latitude", "longitude", mode="before")
    @classmethod
    def reject_boolean(cls, value):
        if isinstance(value, bool):
            raise ValueError("A boolean is not a numeric feature")
        return value

class ShapItem(BaseModel):
    feature: str
    feature_en: str
    amount: float
    pct: float
    type: str  # "base" | "positive" | "negative" | "total"


class FeatureImportanceItem(BaseModel):
    feature: str
    feature_en: str
    pct: float


class SimilarPropertyItem(BaseModel):
    id: int
    title: str
    size: float
    bedrooms: int
    bathrooms: int
    price: float
    price_formatted: str
    city: str
    image_url: Optional[str] = None


class MarketStats(BaseModel):
    city_name: str
    city_avg: float
    property_price: float
    city_max: float
    city_avg_formatted: str
    city_max_formatted: str


class PredictResponse(BaseModel):
    """Point estimate and a heuristic range, with no invented explanations."""
    predicted_price: float
    raw_predicted_price: float
    range_low: float = Field(description="Rounded heuristic lower bound; not a confidence interval")
    range_high: float = Field(description="Rounded heuristic upper bound; not a confidence interval")
    range_method: str
    currency: str
    meter_price: float
    confidence_pct: Optional[float] = None
    area_comparison_pct: Optional[float] = None
    market_stats: Optional[MarketStats] = None
    shap_breakdown: List[ShapItem] = Field(default_factory=list)
    feature_importance: List[FeatureImportanceItem] = Field(default_factory=list)
    similar_properties: List[SimilarPropertyItem] = Field(default_factory=list)
    scenario_delta: Optional[float] = None

# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------

class HealthResponse(BaseModel):
    status: str = Field(description="ok | degraded | error")
    model_loaded: bool = Field(description="True if the regression model loaded successfully.")
    llm_client_ready: bool = Field(description="True if the LLM client initialised successfully.")
    active_sessions: int = Field(description="Number of live chat sessions in memory.")
    llm_backend: str = Field(description="gemini | openai_compatible | unknown")


# ---------------------------------------------------------------------------
# Recommendations & Hybrid Recommendation System
# ---------------------------------------------------------------------------

class RecommendationFilterRequest(BaseModel):
    category: Optional[str] = Field(default="all", description="all | buy | rent | commercial_buy | commercial_rent")
    property_type: Optional[str] = Field(default="all", description="all | Apartment | Villa | ...")
    city: Optional[str] = Field(default="all", description="all | New Cairo City | Sheikh Zayed City | ...")
    price_range_id: Optional[str] = Field(default="all", description="Pre-bucketed price tier ID or 'all'")
    min_price: Optional[float] = Field(default=None, description="Optional minimum price")
    max_price: Optional[float] = Field(default=None, description="Optional maximum price")
    size_range_id: Optional[str] = Field(default="all", description="Pre-bucketed size tier ID or 'all'")
    min_size: Optional[float] = Field(default=None, description="Optional minimum size in m²")
    max_size: Optional[float] = Field(default=None, description="Optional maximum size in m²")
    bedrooms: Optional[Union[str, int, float]] = Field(default="all", description="Number of bedrooms or 'all'")
    bathrooms: Optional[Union[str, int, float]] = Field(default="all", description="Number of bathrooms or 'all'")
    amenities: Optional[List[str]] = Field(default_factory=list, description="List of requested amenities")
    sort: Optional[str] = Field(default="similarity", description="similarity | price_low | price_high")
    limit: Optional[int] = Field(default=6, ge=1, le=100, description="Page size")
    offset: Optional[int] = Field(default=0, ge=0, description="Offset for pagination")


class RecommendationCard(BaseModel):
    id: int
    title: str
    category: str
    category_ar: str
    category_en: str
    property_type: str
    city: str
    city_ar: str
    location: str
    latitude: float
    longitude: float
    price: float
    price_label_ar: str
    price_label_en: str
    size: float
    bedrooms: int
    bathrooms: int
    amenities: List[str] = Field(default_factory=list)
    image_url: str
    images: List[str] = Field(default_factory=list)
    similarity: float = Field(default=0.95)
    cluster: int = Field(default=0)


class RecommendationSearchResponse(BaseModel):
    status: str = Field(default="success")
    total: int = Field(description="Total matching properties across the full catalog")
    limit: int
    offset: int
    items: List[RecommendationCard]


class SimilarPropertiesResponse(BaseModel):
    status: str = Field(default="success")
    property_id: int
    cluster: int
    items: List[RecommendationCard]


