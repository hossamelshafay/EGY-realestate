# Current AI API contracts

Source contract updated 2026-11-22. Prediction and recommendation search/similar
passed in-process HTTP tests with real artifacts and a test-only Firebase override.
Disabled chat and its scripted real-catalog tool loop passed offline. Real Firebase
verification, live provider chat and device requests remain unverified. See
[AI integration status](AI_INTEGRATION.md) for evidence and test commands.
Previous speculative response examples
and confidence/SHAP claims are superseded by this document and schemas.py.

## Random property discovery

`POST /api/recommendations/catalog/sample` requires a Firebase bearer token.
The JSON body includes a category code (`buy`, `rent`, `commercial_buy`, or
`commercial_rent`), a `limit` from 1 to 45, and optional `exclude_ids`
containing up to 45 previously shown listing IDs. The response is an array
of the existing recommendation card shape. Sampling occurs after validating
the category and property type. A response contains distinct IDs and
prefers records outside the exclusion list. It may contain fewer than the
requested number when a category is small.

## Authentication

All `/api/predict*`, `/api/chat` and `/api/recommendations/*` endpoints require:

```http
Authorization: Bearer <Firebase ID token>
```

The server calls Firebase Admin `verify_id_token` for project `real-estate-e1418`
with `check_revoked=True`. No header-only trust or unsigned decoding is accepted.
401: missing/malformed/invalid/expired/revoked token or disabled user.
503: missing Admin dependency/credentials or verification service unavailable.
Firebase Admin credentials use server-process ADC, not Flutter configuration.
GET `/api/health` is public; its status can be degraded while prediction is usable.

## GET /api/predict/options

Returns `features` (the ordered seven names below) and `categories`, containing
`property_type` and `category` string lists from the fitted encoders in the actual
loaded model. No default choice is implied. 503 if the model is unavailable.
Do not hardcode category choices based on notebook comments.

## POST /api/predict

JSON body: seven required features. Unknown fields are rejected.

| Field | Accepted input |
|---|---|
| size | Finite number 20..10000 m², numeric string, or ordered range string with both endpoints within those bounds; a range is converted to its midpoint |
| bedrooms | Finite numeric count 0..20; no hidden-field default |
| bathrooms | Finite numeric count 0..20; no hidden-field default |
| latitude | Finite number 22..32; explicit coordinates |
| longitude | Finite number 24..38; explicit coordinates |
| property_type | Exact fitted encoder value from options |
| category | Exact fitted encoder value from options |

Booleans are rejected as numeric features. Malformed/reversed ranges, missing
features, unsupported categories, out-of-range values and extras return 422.
No silent area fallback, numeric clamping, guessed coordinates or fallback cities.
The former city_id field is no longer accepted.

The saved preprocessing is internal to each fitted ensemble pipeline: five
numeric features through StandardScaler, two categorical features through
OrdinalEncoder. The request supplies raw values. Model output is log1p(price),
inverted with expm1. No fitting or retraining occurs.

| Response field | Meaning |
|---|---|
| predicted_price | Rounded EGP estimate: step 25000 for sale, 500 for rent |
| raw_predicted_price | Actual unrounded expm1(model prediction) |
| range_low / range_high | ±8% of rounded estimate, rounded to the same step; heuristic only |
| range_method | `heuristic_plus_minus_8_percent_rounded` |
| currency | `EGP` for sale or `EGP/month` for rent |
| meter_price | Rounded predicted_price / size |
| confidence_pct | null; no calibrated confidence exists |
| shap_breakdown | Empty list; no SHAP computation is provided |
| feature_importance | Empty list; no verified feature importance is provided |
| market_stats / area_comparison_pct | null; no substituted city/country statistic |
| similar_properties | Empty list; independent price endpoint does not load catalog |
| scenario_delta | null; no artificially forced positive scenario effect |

503: missing model, failed inference, invalid model output or price below rounding
resolution. No fabricated successful response is returned. Server startup checks
feature order, fitted preprocessing and consistent categorical vocabularies.

## Recommendations: search/similar runtime checked offline

All require Firebase ID token verification. Catalog/artifacts load only upon a
recommendation request, so their import/loading cannot block price startup.

- POST `/api/recommendations/search`: RecommendationFilterRequest.
- GET `/api/recommendations/search`: query-parameter variant.
- GET `/api/recommendations/similar/{property_id}`: top_n, 1..20.
- POST `/api/recommendations/batch`: property_ids list.
- GET `/api/recommendations/featured/list`: optional limit.
- GET `/api/recommendations/{property_id}`: one property, 404 if not found.

Filters in schemas.py: category, property_type, city, price_range_id, min_price,
max_price, size_range_id, min_size, max_size, bedrooms, bathrooms, amenities,
sort, limit (1..100), offset (>=0). These legacy filters/defaults are not fully
hardened; basic Apartment/buy search and similar listings passed offline tests.
Search returns status, total, limit, offset,
items. Similar returns status, property_id, cluster, items. Card fields follow
RecommendationCard in schemas.py. Similarity values are not calibrated confidence;
some paths use fixed defaults. Do not display them as verified model certainty.

## POST /api/chat: disabled by default

Request: message (1..4000 characters), optional session_id. A whitespace-only
message is rejected. Response schema: reply, session_id, properties, suggestions,
total_matches, applied_filters. These shapes do not prove provider readiness.
With CHAT_ENABLED=false, valid authenticated requests return 503. No LLM key is
needed for independent models. Enabling chat requires explicit provider setup
and approval for potentially paid calls. Session ownership must be bound to the
verified Firebase UID before enabling multi-user chat.

## GET /api/health

Public response: status, model_loaded, llm_client_ready, active_sessions,
llm_backend. An unconfigured chatbot produces degraded status; inspect the
individual component flags. Recommendations are loaded lazily, so health does
not certify recommendation readiness.

## Flutter transport

Repository -> Datasource -> Dio ApiClient. Token obtained from current Firebase
user for each request. No tokens logged/persisted. Explicit API_BASE_URL required;
release HTTPS enforced. Connect timeout 10s; prediction send/receive timeout 30s.
Chat send/receive timeout is 60s; other model requests use 30s.
Redirects disabled. API errors map to Failure types. Prediction datasource rejects
malformed responses rather than inventing values. Form/result UI is still pending
device validation; existing route remains a placeholder. Recommendation search
and similar-listing repositories and a disabled chat repository are registered
manually in get_it. Their datasources validate responses and return domain
entities. ChatRepositoryImpl defaults to disabled and makes no HTTP request;
provider approval and server UID ownership are required before enabling it.

The legacy backend Front/ demo has no authenticated token flow and still contains
unverified display claims. It is not an integrated client of this contract.
