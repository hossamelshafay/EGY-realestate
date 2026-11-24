# AI integration status

Updated 2026-11-23. Flutter prediction, recommendations, and chat screens are
connected to their existing Cubits, repositories, and routes. See the validation
below for the distinction between Flutter tests and real-device results.

## Catalog discovery and Favorites

The real Parquet has 62,977 rows, unique backend IDs, and 32 property types.
Discovery checks the stored category code, its English category label, and
a compatible property type before sampling. The eligible pool excludes
inconsistent rows and ambiguous mixed-use types such as Land, Whole Building,
Full Floor, and Half Floor. Recommendation search and trained artifacts keep
their existing behavior.

| Home category | API code | Raw rows | Eligible for discovery |
| --- | --- | ---: | ---: |
| Residential for Sale | `buy` | 19,965 | 19,916 |
| Residential for Rent | `rent` | 19,979 | 19,975 |
| Commercial for Sale | `commercial_buy` | 8,953 | 8,450 |
| Commercial for Rent | `commercial_rent` | 14,080 | 13,245 |

- Home requests five unique listings of the selected category. The existing
  horizontal carousel exposes all five cards and indicators when available.
  The local Home search and filter controls refine the current sample.
- View All carries the same category and asks for 15 unique listings. Refresh
  submits the previous IDs for exclusion and fills from those IDs only if
  fewer than 15 alternatives are available. The Cubit ignores late responses
  for superseded requests.
- English and Arabic use one ARB-backed property-type display mapping. Model
  input and catalog filters retain canonical API values. Listing titles and
  locations remain as supplied by the dataset.
- Favorites uses a shared session-aware Cubit and Firestore snapshots at
  `users/{uid}/favorites/{propertyId}`. The scoped rules were deployed with
  owner approval. Seven Firebase Rules API cases passed for owner access,
  cross-account denial, unauthenticated denial, updates, and unrelated paths.

## Final Android check, five-card build

- The ARM64 debug APK now requests five featured properties and was installed
  as an update on both an authorized CPH2159 (Android 13) and RMX1921
  (Android 11). Neither update cleared app data.
- Android 13 displayed live listings for all four Home categories. For each,
  FastAPI returned five unique IDs and all rows matched the requested category.
  Five distinct Commercial for Rent cards were reached by horizontal swipes.
- Commercial for Rent View All returned 15 unique matches. Pull-to-refresh
  returned 15 different IDs and preserved the category. The selected shop's
  Details page matched the View All card, including EGP 40,000 per month.
  The two tested detail listings both served JPEG image content.
- Favorites synchronized between View All and Details, and between Featured
  and Details. A newly saved listing appeared in Favorites after force-stopping
  and relaunching EGY. Only listings saved by the test were removed afterward.
- The physical phone displayed `Apartment` in English and `شقة` in Arabic
  in the live Price Prediction options. The in-place locale switch test also
  confirms the selected API value remains `Apartment`.
- After manual Firebase sign-in on Android 11, prediction returned HTTP 200
  and Flutter displayed EGP 7,725,000 for the standard 130 m² sale apartment.
  The displayed range was EGP 7,100,000–8,350,000.
- An authenticated recommendation search for residential-sale apartments
  returned HTTP 200 and 10,276 matches. The selected listing's Similar
  Properties request returned HTTP 200 and rendered 20 results. On each
  screen, a test favorite appeared in Details and removal in Details updated
  the originating card.
- The approved live Gemini turn ran on Android 11. Flutter displayed its
  loading label and rendered the assistant's reply. FastAPI `POST /api/chat`
  returned HTTP 200. The provider transport recorded one generation request
  to `gemini-3.5-flash-lite`, with HTTP 200 and no retries. New Conversation
  restored the welcome screen without an additional request.
- An unauthenticated phone probe to `POST /api/chat` returned HTTP 401 and
  made zero provider calls. UID ownership regressions passed. The Gemini API
  key remained in the backend configuration.
- After the successful turn, the normal local FastAPI server was restarted
  with Gemini enabled. Health returned HTTP 200 with `GeminiClient` ready.
  Both phone-only Windows firewall rules were removed. The Android 11
  USB stay-awake setting was verified at its original value. The Android 13
  phone had disconnected before that setting could be checked.
- `flutter analyze` reported no issues, the full Flutter suite passed 136
  tests, 74 targeted Flutter tests passed, and 15 backend tests passed. A
  Flutter widget test verified the chat spinner, localized failure UI, and
  reset without an additional request.

### Discovery verification

- Flutter analysis found no issues. All 73 targeted tests and all 135 tests
  in the full Flutter suite passed,
  including English/Arabic type labels, a locale change with a selected
  canonical value, Auth-to-Home, category navigation, a 15-item refresh,
  stale category responses, and Favorites state across accounts and Cubit
  lifetimes.
- Nine FastAPI tests and six offline backend regressions passed. Real
  Parquet samples covered all four category mappings and excluded the
  previously returned IDs when the catalog had alternatives.
- Android 13 installed and launched the discovery build as an update. The
  authenticated phone reached FastAPI at `192.168.1.8:8000` and displayed real
  listings in all four Home categories. That earlier build showed the
  first five carousel indicators with a total of 45 properties. The device
  disconnected before swipe traversal, View All refresh, Favorites restart,
  and the Android locale switch could be checked. The final ARM64 APK with
  revised Favorites labels built successfully and awaits reconnection. The
  temporary firewall rule for the device was removed.

### Gemini configuration and pre-approval checks

- Backend environment: `CHAT_ENABLED=true`, `LLM_PROVIDER=gemini`,
  `GEMINI_MODEL=gemini-3.5-flash-lite`, and the existing server-side
  `GEMINI_API_KEY`. Set `GOOGLE_APPLICATION_CREDENTIALS` for Firebase Admin.
- Flutter: `--dart-define=ENABLE_LIVE_CHAT=true` and the verified
  `--dart-define=API_BASE_URL=http://192.168.1.8:8000` for local Android testing.
  Chat uses the same authenticated Dio client as prediction and discovery.
- Before approval, both chat gates were kept off in the earlier build and
  server. The configured
  model's read-only metadata returned HTTP 200 and listed `generateContent`.
  No Gemini generation request was made in that earlier check. The subsequently
  approved single turn is recorded above. A tool-assisted turn can use
  multiple provider calls.

## Auth-to-Home continuation

- Email, registration, Google, and the onboarding handoff exercise real Lottie
  controller playback in widget tests. Each stays on Auth until playback
  completes, then reveals Home using the same header and logo. The outgoing
  form is offstage during the reveal and disposed when the reveal finishes.
- Onboarding pushes Auth onto its stack. A router refresh reevaluated the base
  onboarding location and left the pushed Login visible after feedback.
  The completion callback now releases the session gate and commits Home,
  dropping onboarding while preserving the shared shell and logo.
- Flutter's result status listener handles both normal playback and direct
  completion for reduced motion. The extra per-value listener was removed.

## Current Flutter validation

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `test/features/authentication` | 29 passed |
| `test/features/home` | 13 passed |
| `test/features/ai_integration` | 20 passed |
| `test/features/price_prediction` | 8 passed |
| Full Flutter suite | 132 passed |

The tests include EN/AR UI, reduced motion, failure feedback, scrollable
headers, and both Home theme contexts. Device performance remains unverified.

## Live backend and device validation

- The host Wi-Fi IPv4 address is `192.168.1.8`. FastAPI started on port `8000`
  with Firebase Admin application-default credentials and `CHAT_ENABLED=false`.
- `/api/health` returned HTTP 200 with `model_loaded: true`, zero sessions and
  `llm_backend: disabled`. Health reports `degraded` while chat is disabled.
- Prediction options returned HTTP 401 for missing and invalid Firebase ID
  tokens. Recommendation search and chat each returned HTTP 401 without a
  token. Acceptance of a signed-in device's token requires a device session.
- The debug APK built at `build/app/outputs/flutter-apk/app-debug.apk` with
  `API_BASE_URL=http://192.168.1.8:8000`. The original build log stopped during
  Flutter engine downloads. The retry used a workspace-local Flutter Maven
  mirror with the recovered ARM64 JAR checked against the official object ETag.
- ADB detected an authorized RMX1921 running Android 11 with an ARM64 CPU.
  At the prior checkpoint Android rejected both the universal APK and the smaller
  `build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk` for insufficient
  internal storage with about 654 MB available. The existing app data was
  preserved. Free at least 1 GB, keep the phone unlocked and USB debugging
  authorized, then retry installation and sign in manually. Prediction and
  recommendation inference require a signed-in device session. The later
  installation and authenticated device results are recorded below.
- No Gemini request was made during this continuation. Chat uses
  `ENABLE_LIVE_CHAT`, which defaults to false in Flutter and short-circuits
  requests before HTTP. Backend chat is also disabled independently.

## Android device validation, 2026-11-23

- ADB detected an authorized ARM64 CPH2159 running Android 13 with 36 GB of
  available internal storage. The existing 109 MB ARM64 debug APK was current.
  `adb install -r` succeeded over the existing app and `MainActivity` launched.
  No rebuild or app-data reset was needed.
- From the phone, `/api/health` returned HTTP 200 with the model loaded and
  chat disabled. `/api/chat` returned HTTP 401 for the phone's unauthenticated
  probe. These requests exercised the LAN path without calling Gemini.
- The Public firewall initially blocked the phone's connection. A temporary
  inbound rule restricted access to that phone's Wi-Fi address on TCP 8000.
  The Windows host clock was also about 24 minutes behind the phone and
  Google's HTTPS clock. After synchronizing Windows, the same Firebase
  session passed the server's existing verification checks. The temporary
  firewall rule was removed after validation.
- Prediction options and `POST /api/predict` returned HTTP 200. For a 130 m²
  apartment for sale with 3 bedrooms, 2 bathrooms and coordinates 30.03, 31.47,
  the Arabic Flutter screen displayed EGP 7,725,000 and the heuristic range
  EGP 7,100,000 to 8,350,000.
- `POST /api/recommendations/search` returned HTTP 200 and Flutter rendered
  listings with 62,977 total matches. The Similar Properties action for
  listing `52725100` returned HTTP 200 and rendered 20 matches.
- AI Assistant opened with its welcome screen and input. Sending a test
  message showed the unavailable state, and New Conversation restored the
  welcome screen. The Flutter chat gate made no chat request, backend health
  still showed zero sessions, and no Gemini request was made.

## Environment verified

- Interpreter: `EGY_DEVELOPMENT_ai/.venv/Scripts/python.exe`.
- Elevated read-only version check succeeded: Python 3.13.5.
- Saved model imports/inference succeeded with scikit-learn 1.9.1, numpy 2.5.5,
  pandas 3.1.1, XGBoost 3.4.1 and joblib 1.6.0.
- Used the existing environment; no Python packages, permissions, model artifacts,
  Python backend source or Firebase configuration were changed.
- Flutter dependency resolution succeeded with elevated SDK/cache access. Dio
  5.11.1 and its transitive dependencies are now in pubspec.lock.

## Price prediction verified offline

Artifact: `models/regression/final_price_prediction_model.joblib`.
SHA-256: `0d95ec837a4721145ed1e0511c942409f6b8e67970da21d65ceea8813142efce`.

The real StackingRegressor loaded with fitted StandardScaler/OrdinalEncoder
pipelines. Seven raw features, in order: size, bedrooms, bathrooms, latitude,
longitude, property_type, category. Flutter must not scale or encode inputs.
The options endpoint provides fitted categorical vocabularies.

For size=130, bedrooms=3, bathrooms=2, latitude=30.03, longitude=31.47,
property_type=Apartment, category=buy:

- Log prediction: 15.859755953371762.
- Raw expm1 estimate: EGP 7,723,327.279427491.
- API rounded estimate: EGP 7,725,000.
- Heuristic rounded range: EGP 7,100,000 to 8,350,000. This is not a confidence interval.
- Confidence remains null; SHAP and feature importance remain empty.

Existing six backend tests passed: real inference, invalid inputs, model options,
protected-route rejection, disabled chat and mocked Firebase SDK verification.
Successful protected requests use a test-only Firebase dependency override.
These checks do not establish real credential validity or model accuracy.

## Hybrid recommendations verified offline

The catalog contains 62,977 listings. Feature matrix: 62,977 x 191; neighbor
indices/scores: 62,977 x 50. The existing smoke script passed its dimension,
ID-map size, unique-neighbor, self-exclusion and cluster checks for one seed.
It returned six actual catalog listings. This is a smoke sample, not an exhaustive
mapping or recommendation-quality audit.

New in-process HTTP checks passed Apartment/buy search and similar-listing
responses with real artifacts. Similarity values are not calibrated confidence;
some engine paths supply fixed defaults. Flutter entities exclude those scores.

## Chatbot checked with scripted provider only

A scripted FakeLLMClient drove the real ChatSession tool loop through
search_properties against the real catalog. Returned listing IDs and match count
matched the direct tool output. No live provider was initialized or contacted.
A separate startup/HTTP check confirmed disabled chat returns 503.

CHAT_ENABLED=false was forced for every Python test invocation. New offline tests
block external socket connections (Windows asyncio's internal loopback sockets
are allowed). Gemini and other paid provider requests were not made.

The current server source passes the verified Firebase UID to its chat session
manager and checks ownership before reuse. Live multi-user isolation and
provider generation remain outside this follow-up. Chat was kept disabled.

## Flutter integration

Prediction retains its existing Repository/Datasource/Cubit layers. Added typed
recommendation search and neighbor repositories, a chat repository, strict JSON
decoding, immutable listing/result entities and manual get_it registrations.
The shared authenticated Dio client obtains a fresh Firebase token for each
request, disables redirects and uses 30s model / 60s chat send/receive timeouts.

ChatRepositoryImpl defaults to disabled and rejects calls before HTTP. Tests
explicitly enable it with a recording fake transport. Chat session IDs are not
persisted.

Repository tests cover filters, pagination, invalid/duplicate/self listings,
malformed responses, nullable chat facts, auth/outage/network failure mapping and
the disabled chat gate. Transport tests check fresh tokens, timeouts, redirects,
configuration validation and rejection before HTTP when signed out.

## Historical offline validation

From EGY_DEVELOPMENT_ai, using elevated execution for this sandbox:

```powershell
$env:CHAT_ENABLED='false'
.venv/Scripts/python.exe scripts/offline_price_smoke.py
.venv/Scripts/python.exe scripts/offline_hybrid_smoke.py
.venv/Scripts/python.exe -m unittest discover -s tests -v
.venv/Scripts/python.exe -m unittest discover -s ../test/backend -v
```

Python result: 9 tests passed plus both artifact smoke scripts. Starlette emits
an httpx deprecation warning; it did not fail the tests. No package upgrade was made.

Flutter focused validation: 18 tests passed for prediction and AI integration.
Targeted Dart analysis across AI source, DI and focused tests: no issues found.
Changed Dart files were formatted. New source/test files stay below 400 lines.

Project-wide `flutter analyze --no-pub` completed with 27 diagnostics outside
the AI integration files: one unused-import warning and 26 style infos in
auth/home/onboarding/splash/router code and tests. There were no analysis errors.
The full Flutter suite was also attempted: it reached 99 passing and 16 failing
tests, with auth/home animation/layout failures (including RenderAnimatedSize
mutation assertions and opacity/scroll expectations), then stopped making
progress in auth_shell_motion_test. The run was interrupted; it is not a passing
full-suite result. Those UI files were not changed in this continuation.

Remaining live gates include authenticated chat transport, multi-user chat
verification, and explicit provider approval before live chat. No secure
credential values were logged. No server was deployed.
