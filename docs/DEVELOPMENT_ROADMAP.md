# EGY DEVELOPMENT — Development Roadmap

> A phased plan for building the EGY DEVELOPMENT Flutter mobile application on top of the existing Python AI backend.

**Phase 1A.3 cinematic Home, 2026-11-25.** Home stages its entrance and flips
the Featured area between categories in the current reading direction. The
stacked deck retains autoplay and prefetch. Search opens as a modal panel with
a retained query, using catalog samples and the existing recommendation
location and type filters. Property Details uses a shared image transition and
renders available facts, amenities, and photos. The current catalog omits
descriptions and contact information.

Flutter analysis and 146 tests passed. The Android debug APK installed in place
and retained sign-in. Home and Search were checked on-device, including keyboard
and query retention. The phone could not reach the local catalog over Wi-Fi, so
live-listing visual checks remain pending. Phase 1B requires owner approval.

**Discovery and Favorites follow-up, 2026-11-23.** The catalog now powers
Home, View All, and property details with canonical category filters. The
first Favorites implementation uses UID-scoped Firestore rules and shared
listing controls. Property type localization covers English and Arabic.
Live Gemini remains approval-gated. See [AI integration status](AI_INTEGRATION.md)
for deployment and verification evidence.

**Phase 1A navigation review.** Authenticated screens now share Reveal
navigation and an inward-curved header. Home retains its outward curve.
Flutter analyze and all 139 Flutter tests passed, and the ARM64 debug APK
built successfully. The Android phone disconnected before installation,
so physical visual verification is pending.

**Phase 1A.1 motion review.** Authenticated routes use a 400 ms crossfade.
Featured Properties keeps the current card visible while fetching five more
listings in the selected category. Home applies text, type, and city filters
locally because the catalog sampler accepts only a category and up to 45
excluded IDs. The app also deduplicates against the full current deck.
Flutter analyze and all 142 Flutter tests passed. The updated ARM64 debug APK
installed over the existing app on Android 11. The signed-in Home session was
retained, the Arabic carousel advanced beyond the first five real listings,
and Property Details opened and returned to Home. Phase 1A.1 is at the review
gate.

---

## Phase 0: Repository Audit and Documentation ✅

**Objective:** Inspect the existing codebase, catalog assets, and produce comprehensive project documentation before writing any application code.

**Prerequisites:** None — this is the starting phase.

**Tasks:**
- Audit the Flutter project structure and dependencies
- Audit the Python AI backend: endpoints, models, datasets
- Verify all 19 design reference images in `docs/design_references/`
- Extract the visual design language (colors, typography, spacing, layout patterns)
- Create `docs/MASTER_PLAN.md`
- Create `docs/ARCHITECTURE.md`
- Create `docs/FEATURES.md`
- Create `docs/DESIGN_SYSTEM.md`
- Create `docs/DEVELOPMENT_ROADMAP.md` (this file)
- Create `docs/TESTING_STRATEGY.md`
- Create `docs/design_references/README.md`
- Create `.agents/rules/egy-development.md` project rules

**Relevant Files:**
- `pubspec.yaml`
- `lib/main.dart`
- `lib/firebase_options.dart`
- `EGY_DEVELOPMENT_ai/` (entire backend tree)
- `docs/design_references/*.png, *.jpg`

**Dependencies:** None.

**Testing Requirements:** N/A — documentation phase.

**Acceptance Criteria:**
- All documentation files exist and are internally consistent
- Design system tokens match inspected screenshots
- API endpoint catalog matches backend source

**Definition of Done:** All 7+ documentation files created, reviewed, and committed.

**Risks:**
- Misreading screenshots without designer confirmation
- Backend endpoints may change before Flutter integration

**Expected Deliverables:** Complete `docs/` folder and `.agents/rules/` file.

---

## Phase 1: Architecture Foundation

**Objective:** Scaffold the minimal working app shell with correct folder structure, dependency injection, error abstractions, theme tokens, and a booting `App` widget. Keep this phase lean — no feature screens, no empty placeholder directories, no unused infrastructure.

**Prerequisites:** Phase 0 complete.

**Tasks:**
- Create only the directories that will contain actual files in this phase:
  - `lib/app/` — `app.dart`, `router/`, `theme/`, `di/`
  - `lib/core/constants/`, `lib/core/errors/`, `lib/core/storage/`, `lib/core/utils/`
- Do **NOT** pre-create empty `lib/features/<x>/` directories — create feature directories only when implementing that feature
- Add `get_it` to `pubspec.yaml` for DI — **do NOT add `injectable` or `build_runner` at this stage**
- Create `app/di/injection.dart` with explicit manual `get_it` registration (readable, no code generation)
- Define `core/errors/failures.dart` (sealed Failure class) and `core/errors/exceptions.dart`
- Create `core/constants/api_constants.dart` — backend base URL as `--dart-define` configurable constant; document that `localhost` is invalid on physical devices
- Create `core/constants/app_constants.dart` (durations, limits)
- Create `app/theme/app_colors.dart` with semantic color tokens from the design system
- Create `app/theme/app_text_styles.dart`
- Create `app/theme/app_theme.dart` (light `ThemeData`; dark stub — do NOT implement dark colors)
- Create `app/app.dart` (root `MaterialApp.router` placeholder with theme wired)
- Update `lib/main.dart`: call `Firebase.initializeApp`, call `setupDependencies()`, then `runApp(App())`
- Create `core/storage/local_storage.dart` (SharedPreferences wrapper — language and onboarding flag only)
- **Do NOT create `core/services/logger_service.dart` or other optional infrastructure unless immediately needed**

**Relevant Files:**
- `lib/main.dart`
- `lib/app/` (new)
- `lib/core/` (new)
- `pubspec.yaml`

**Dependencies (packages):**
- `get_it` only — **do NOT add `injectable`/`injectable_generator`/`build_runner` in Phase 1**
- `shared_preferences`
- `firebase_core` (already present)

**Testing Requirements:**
- Unit test for `Failure` classes
- Verify DI container resolves all manually registered singletons on app startup

**Acceptance Criteria:**
- `flutter run` launches a blank `App` shell with no errors and no debug asserts
- DI container initialises without exceptions
- Theme tokens match `docs/DESIGN_SYSTEM.md` color table
- No empty feature directories exist

**Definition of Done:** Minimal folder structure in place, DI wired manually, theme tokens defined, app boots cleanly. Nothing created that is not immediately used.

**Risks:**
- Over-engineering DI at this stage — keep registration minimal
- Theme token drift if design system doc is inaccurate

**Expected Deliverables:** `lib/app/`, `lib/core/`, updated `pubspec.yaml`, working `App` shell.

---

## Phase 2: Design System and Navigation

**Objective:** Implement the reusable widget library, app-wide theming, router configuration, Drawer skeleton, and localization infrastructure.

**Prerequisites:** Phase 1 complete.

**Tasks:**
- Build `core/widgets/app_header.dart` — navy gradient header with optional back button, title, actions
- Build `core/widgets/primary_button.dart` — gold gradient elevated button
- Build `core/widgets/app_text_field.dart` — outlined text field with label, error state
- Build `core/widgets/category_chip.dart` — orange active / gray inactive chip
- Build `core/widgets/property_card.dart` — image, price, details, heart icon
- Build `core/widgets/app_dropdown.dart` — styled dropdown with label
- Build `core/widgets/loading_indicator.dart`
- Build `core/widgets/error_view.dart`
- Configure `go_router` in `app/router/app_router.dart` with initial routes (splash, onboarding, login, home)
- Implement auth-aware redirect guards (placeholder — wired in Phase 4)
- Create `app/router/route_names.dart` constants
- Build Drawer skeleton in `core/widgets/app_drawer.dart` (navy gradient, menu items, close button)
- Set up `flutter_localizations` and `intl` in `pubspec.yaml`
- Create `app/localization/` with `app_en.arb` and `app_ar.arb` seed files
- Generate localisation delegates
- Wire locale switching in `App`

**Relevant Files:**
- `lib/core/widgets/` (new)
- `lib/app/router/` (new)
- `lib/app/localization/` (new)
- `docs/DESIGN_SYSTEM.md`
- `docs/design_references/`

**Dependencies (packages):**
- `go_router`
- `flutter_localizations` (SDK)
- `intl`

**Testing Requirements:**
- Widget tests for every reusable widget (render, tap callbacks, states)
- Golden tests for `AppHeader`, `PrimaryButton`, `PropertyCard`
- Router test: initial route resolves

**Acceptance Criteria:**
- All reusable widgets render correctly with mock data
- Router navigates between placeholder screens
- Drawer opens/closes
- Locale switches between EN and AR, layout flips to RTL

**Definition of Done:** Widget library complete with tests, router navigable, localisation toggleable.

**Risks:**
- Widget API may need revision when real screens are built — keep APIs small and extensible
- RTL edge cases in custom widgets

**Expected Deliverables:** `core/widgets/`, `app/router/`, `app/localization/`, widget tests.

---

## Phase 3: Splash and Onboarding

**Objective:** Implement the splash/welcome screen and the 3-page vertical-swipe onboarding flow, persisting completion state.

**Prerequisites:** Phase 2 complete.

**Tasks:**
- Create `features/splash/` with `splash_screen.dart`
  - EGY gold logo centred
  - Egyptian skyline illustration at bottom
  - "Get Started" navy button
  - EN / AR language selector
- Create `features/onboarding/` with `onboarding_screen.dart`
  - PageView with 3 pages (vertical swipe axis)
  - 3D illustration, title, subtitle per page
  - Page indicator dots
  - "Swipe Up" indicator on first page
  - "Skip" button
- Create `features/onboarding/cubit/onboarding_cubit.dart` (track current page)
- Persist onboarding completion via `SharedPreferences`
- Router guard: skip onboarding if already completed

**Relevant Files:**
- `lib/features/splash/`
- `lib/features/onboarding/`
- `docs/design_references/01_splash.png`
- `docs/design_references/02_onboardingone.png`
- `docs/design_references/02_onboardingtwo.png`
- `docs/design_references/02_onboardingthree.png`

**Dependencies (packages):**
- `shared_preferences` (already added)
- `smooth_page_indicator` (optional — or custom dots)

**Testing Requirements:**
- Widget test: splash renders logo, button, language selector
- Widget test: onboarding swipes through 3 pages
- Unit test: onboarding cubit page transitions
- Unit test: completion flag persisted and read correctly

**Acceptance Criteria:**
- Splash screen matches `01_splash.png` layout
- Onboarding pages match `02_onboarding*.png` layouts
- Completing onboarding persists; relaunch skips to login
- Language selector toggles locale

**Definition of Done:** Splash + onboarding screens pixel-faithful, completion persisted, tests pass.

**Risks:**
- Placeholder illustrations until real assets are provided
- Vertical swipe may conflict with system gestures on some devices

**Expected Deliverables:** `features/splash/`, `features/onboarding/`, onboarding cubit + tests.

---

## Phase 4: Firebase Authentication

**Objective:** Implement Login, Register, and Forgot Password screens with Firebase Auth integration, auth state management, and auth-aware routing.

**Prerequisites:** Phase 3 complete; Firebase already configured.

**Tasks:**
- Create `features/authentication/data/` with `auth_repository.dart` (Firebase Auth wrapper)
- Create `features/authentication/cubit/auth_cubit.dart` — states: initial, loading, authenticated, unauthenticated, error
- Create `features/authentication/presentation/login_screen.dart`
  - Navy header with EGY logo
  - White rounded panel
  - Email + password fields
  - Primary "Log In" button — **use the color shown in `03_login.jpg`; verify against the actual design reference before coding**
  - "Forgot Password?" link
  - Google / Apple social login buttons
  - "Don't have an account? Register" link
- Create `features/authentication/presentation/register_screen.dart`
  - Similar to login with additional fields (name, confirm password)
  - Gold "Register" button
- Create `features/authentication/presentation/forgot_password_screen.dart`
  - Email field + gold "Send Reset Link" button
- Implement form validation (email format, password length ≥ 8, password match)
- Wire `AuthCubit` into router redirect — unauthenticated → login, authenticated → home
- Add `firebase_auth` and `google_sign_in` to `pubspec.yaml`

**Relevant Files:**
- `lib/features/authentication/`
- `lib/firebase_options.dart`
- `docs/design_references/03_login.jpg`
- `docs/design_references/04_register.jpg`
- `docs/design_references/17_forgetpass.jpg`

**Dependencies (packages):**
- `firebase_auth`
- `google_sign_in`
- `sign_in_with_apple` (iOS)
- `flutter_bloc` / `bloc`

**Testing Requirements:**
- Unit tests: `AuthCubit` all state transitions (login success, login failure, register, reset password)
- Unit tests: form validation logic
- Widget tests: login screen renders all elements, error states shown
- Integration test: full login → home flow (with mocked Firebase)

**Acceptance Criteria:**
- Login screen matches `03_login.jpg`
- Register screen matches `04_register.jpg`
- Forgot password screen matches `17_forgetpass.jpg`
- Successful login navigates to Home
- Auth errors display user-friendly messages
- Router redirects unauthenticated users to login

**Definition of Done:** Auth screens complete, Firebase Auth integrated, auth-aware routing works, cubit tests pass.

**Risks:**
- Google Sign-In requires SHA-1 fingerprints configured in Firebase Console
- Apple Sign-In requires Apple Developer account setup
- Social login may not work in emulator without proper config

**Expected Deliverables:** `features/authentication/`, auth cubit, auth repository, updated router guards.

---

## Phase 5: Home and Navigation Drawer

**Current session:** Home UI, the shared Auth-to-Home morph and drawer shell are implemented in source. Analysis, tests, APK compilation and device review are still pending because this environment cannot access the installed SDK cache. Phase 5 is not marked complete; see [Home implementation](HOME_IMPLEMENTATION.md).

**Objective:** Build the Home screen with all sections (AI banner, search, categories, featured carousel, AI tools) and the full navigation Drawer.

**Prerequisites:** Phase 4 complete.

**Tasks:**
- Create `features/home/presentation/home_screen.dart`
  - Navy header with greeting ("Hello, Name"), theme toggle icon, hamburger menu
  - AI Assistant promotional banner (robot illustration, "Chat with AI" button)
  - Search bar (decorative or functional)
  - Horizontal category chips (All, Apartment, Villa, Studio, etc.)
  - Featured properties horizontal carousel (PropertyCard widgets)
  - AI Tools section: 2 cards (Recommendations, Price Prediction) with icons
- Create `features/home/cubit/home_cubit.dart` — manage selected category, featured properties
- Complete `core/widgets/app_drawer.dart`
  - Full-height navy gradient background
  - Profile photo (circular), user name, "EGY Member" label
  - Gold-accented menu items: AI Recommendations, Price Prediction
  - Regular menu items: Favorites, Settings, Language toggle
  - Close (X) button top-right
  - Logout button at bottom
- Wire Drawer navigation to actual routes
- Implement theme toggle (light/dark switch)

**Relevant Files:**
- `lib/features/home/`
- `lib/core/widgets/app_drawer.dart`
- `docs/design_references/05_home.jpg`
- `docs/design_references/06_navigation_drawer.jpg`

**Dependencies (packages):**
- `cached_network_image` (property images)
- `carousel_slider` or `flutter_carousel`

**Testing Requirements:**
- Widget test: Home screen renders all sections
- Widget test: Drawer opens, displays menu items, navigates
- Unit test: `HomeCubit` category selection
- Widget test: theme toggle changes theme

**Acceptance Criteria:**
- Home screen matches `05_home.jpg` layout
- Drawer matches `06_navigation_drawer.jpg`
- Navigation from Drawer items routes to correct screens
- Theme toggle switches light ↔ dark

**Definition of Done:** Home + Drawer fully functional, navigable, visually matched, tests pass.

**Risks:**
- Featured properties require backend data or mock data
- Greeting requires auth user display name

**Expected Deliverables:** `features/home/`, completed `app_drawer.dart`, home cubit + tests.

---

## Phase 6: Property Listings and Details

**Objective:** Build property card listings (search results, featured) and a full property detail page with image gallery.

**Prerequisites:** Phase 5 complete.

**Tasks:**
- Create `features/property_search/presentation/property_list_screen.dart`
  - Navy header with search/filter options
  - Scrollable list of `PropertyCard` widgets
  - Pull-to-refresh
  - Empty state
- Create `features/property_details/presentation/property_detail_screen.dart`
  - Image gallery (swipeable hero images)
  - Property title, price, location
  - Details grid (beds, baths, area, type)
  - Description text
  - Amenities chips
  - Favourite (heart) toggle
  - "Contact" or "AI Chat about this" action
- Create `features/property_details/cubit/property_detail_cubit.dart`
- Create data models: `PropertyModel`, `PropertyImage`
- Add `PropertyCard` tap → navigate to detail page

**Relevant Files:**
- `lib/features/property_search/`
- `lib/features/property_details/`
- `lib/core/widgets/property_card.dart` (already built)
- `docs/design_references/08_recommendation_results.jpg` (property cards reference)

**Dependencies (packages):**
- `cached_network_image` (already added)
- `photo_view` (image gallery zoom)

**Testing Requirements:**
- Widget test: property list renders cards
- Widget test: detail page shows all property info
- Unit test: `PropertyDetailCubit` state transitions
- Unit test: `PropertyModel.fromJson()` mapping

**Acceptance Criteria:**
- Property cards show image, title, price, location, bed/bath counts
- Detail page displays full property info with gallery
- Favourite toggle animates and updates state
- Navigating back returns to list at same scroll position

**Definition of Done:** Property list + detail screens complete, model mapping tested, navigation works.

**Risks:**
- Property images may be URLs from backend — need caching strategy
- Large lists may need pagination

**Expected Deliverables:** `features/property_search/`, `features/property_details/`, property models.

---

## Phase 7: Favorites

**Objective:** Implement save/remove favourites with **Firestore as the source of truth** and a dedicated Favorites list page. Local caching is optional and should not introduce Hive.

**Prerequisites:** Phase 6 complete; Firebase Auth active.

**Tasks:**
- Create `features/favorites/data/favorites_repository.dart` — Firestore CRUD (user-scoped collection under `users/{uid}/favorites`)
- Create `features/favorites/cubit/favorites_cubit.dart` — states: loading, loaded (list), error
- Create `features/favorites/presentation/favorites_screen.dart`
  - Navy header
  - List of favourite `PropertyCard` widgets with filled heart icons
  - Swipe-to-remove or toggle heart to remove
  - Empty state illustration
- Wire heart icon on `PropertyCard` and `PropertyDetailScreen` to `FavoritesCubit`
- Add `cloud_firestore` to `pubspec.yaml`
- Firestore security rules: authenticated user can only read/write own favourites collection
- On sign-out: clear in-memory favourites state so the next user starts fresh
- **Do NOT add Hive** — SharedPreferences may be used for a lightweight read-through ID cache if needed; evaluate first whether Firestore offline cache (`Firestore.instance.settings`) is sufficient

**Relevant Files:**
- `lib/features/favorites/`
- `lib/core/widgets/property_card.dart` (heart icon state)
- `docs/design_references/12_favorites.png`

**Dependencies (packages):**
- `cloud_firestore`

**Testing Requirements:**
- Unit test: `FavoritesCubit` add, remove, load
- Unit test: `FavoritesRepository` with mocked Firestore
- Widget test: favourites screen renders list, empty state
- Integration test: add favourite → appears in list → remove → disappears

**Acceptance Criteria:**
- Favourites screen matches `12_favorites.png`
- Heart icon state syncs across property card, detail, and favourites list
- Data persists across app restarts (Firestore)
- Only authenticated user's favourites are accessible

**Definition of Done:** Favourites fully functional end-to-end, Firestore integrated, tests pass.

**Risks:**
- Firestore offline cache may cause stale data
- Need to handle sign-out clearing local favourites state

**Expected Deliverables:** `features/favorites/`, Firestore rules, favourites cubit + tests.

---

## Phase 8: AI Backend Preparation

**Objective:** Set up the HTTP client, API service layer, Dart model classes for all backend responses, and verify connectivity with a health check.

**Prerequisites:** Phase 1 complete (can run in parallel with Phases 5–7).

**Tasks:**
- Create `core/network/api_client.dart` — Dio HTTP client with base URL, interceptors (auth token, logging, error handling)
- Create `core/network/api_interceptors.dart` — attach Firebase ID token to requests
- Create `core/network/api_exceptions.dart` — map HTTP errors to domain Failures
- Create model classes:
  - `PredictionRequest`, `PredictionResponse` (price, range, SHAP values, similar properties, market stats)
  - `RecommendationSearchRequest`, `RecommendationSearchResponse`
  - `RecommendationItem`
  - `ChatMessage`, `ChatRequest`, `ChatResponse`
  - `HealthCheckResponse`
- Create `core/services/api_service.dart` — typed methods for each endpoint:
  - `healthCheck()` → `GET /api/health`
  - `predict(PredictionRequest)` → `POST /api/predict`
  - `searchRecommendations(RecommendationSearchRequest)` → `POST /api/recommendations/search`
  - `getRecommendation(String id)` → `GET /api/recommendations/{id}`
  - `getSimilar(String id)` → `GET /api/recommendations/similar/{id}`
  - `getFeatured()` → `GET /api/recommendations/featured/list`
  - `chat(ChatRequest)` → `POST /api/chat`
- Register `ApiClient` and `ApiService` in DI container
- Write a health check smoke test

**Relevant Files:**
- `lib/core/network/` (new)
- `lib/core/services/api_service.dart` (new)
- `EGY_DEVELOPMENT_ai/api/` (endpoint reference)
- `EGY_DEVELOPMENT_ai/schemas.py` (request/response schemas)

**Dependencies (packages):**
- `dio`
- `retrofit` (optional, or manual)
- `json_annotation`, `json_serializable`, `build_runner`
- `firebase_auth` (for ID token)

**Testing Requirements:**
- Unit test: every model `fromJson()` and `toJson()` with sample payloads
- Unit test: `ApiService` methods with mocked Dio
- Unit test: error mapping (401 → AuthFailure, 500 → ServerFailure, timeout → NetworkFailure)
- Smoke test: health check against running backend (skippable in CI)

**Acceptance Criteria:**
- All model classes round-trip JSON correctly
- `ApiService.healthCheck()` returns success against running backend
- Auth token attached to outgoing requests
- Network errors mapped to typed `Failure` objects

**Definition of Done:** API layer complete, all models tested, health check passes against live backend.

**Risks:**
- Backend response schemas may differ from documentation — test against real responses
- Backend may not be deployed yet — need configurable base URL

**Expected Deliverables:** `core/network/`, `core/services/api_service.dart`, model classes, unit tests.

---

## Phase 9: AI Recommendations

**Objective:** Build the recommendation filter screen and results display, connecting to the backend `POST /api/recommendations/search` endpoint.

**Prerequisites:** Phase 8 complete; Phase 2 widgets available.

**Tasks:**
- Create `features/recommendations/presentation/recommendation_filters_screen.dart`
  - Navy header
  - Category chips (Apartment, Villa, Studio, etc.)
  - Dropdowns: Location (city), Property Type, Area range, Budget range, Bedrooms, Bathrooms
  - Amenity chips (multi-select: Pool, Garden, Parking, etc.)
  - Gold "Search" button
- Create `features/recommendations/presentation/recommendation_results_screen.dart`
  - Navy header with filter summary
  - List of `PropertyCard` results
  - Sorting options (price, relevance) — **PROPOSED, implement only if the backend search endpoint supports a sort parameter**
  - Pagination / infinite scroll — **CONDITIONAL**: implement only if the backend returns a pagination cursor or `has_more` indicator
  - Empty state
- Create `features/recommendations/cubit/recommendations_cubit.dart`
  - States: initial, filtersSet, loading, loaded(results, hasMore), error
- Create `features/recommendations/data/recommendations_repository.dart`
  - Calls `ApiService.searchRecommendations()`
  - Maps response to domain models
- Wire Drawer "Recommendations" item → filter screen

**Relevant Files:**
- `lib/features/recommendations/`
- `docs/design_references/07_recommendation_filters.jpg`
- `docs/design_references/08_recommendation_results.jpg`

**Dependencies (packages):** None new (uses existing widgets + API layer).

**Testing Requirements:**
- Unit test: `RecommendationsCubit` all states (set filters, search, paginate, error)
- Unit test: `RecommendationsRepository` with mocked API service
- Widget test: filter screen renders all dropdowns and chips
- Widget test: results screen renders cards, handles empty state

**Acceptance Criteria:**
- Filter screen matches `07_recommendation_filters.jpg`
- Results screen matches `08_recommendation_results.jpg`
- Selecting filters and tapping Search returns relevant results
- Pagination loads more results on scroll — **only if backend provides pagination support; otherwise show full result set without infinite scroll**
- Error states display retry option

**Definition of Done:** Recommendation flow end-to-end functional, UI matches designs, tests pass.

**Risks:**
- Backend search may be slow for complex queries — add timeout handling
- Filter options (cities, types) need to be sourced or hardcoded

**Expected Deliverables:** `features/recommendations/`, cubit, repository, widget tests.

---

## Phase 10: Price Prediction

**Objective:** Build the price prediction input form and results display, connecting to `POST /api/predict`.

**Prerequisites:** Phase 8 complete; Phase 2 widgets available.

**Tasks:**
- Create `features/price_prediction/presentation/prediction_form_screen.dart`
  - Navy header
  - Category chips (property type)
  - Dropdowns: Location (city), Property Type, Area, Bedrooms, Bathrooms
  - Additional fields as required by backend schema
  - Gold "Calculate" button
- Create `features/price_prediction/presentation/prediction_results_screen.dart`
  - Predicted price (large, prominent, formatted in EGP)
  - Price range (low/high) — always present
  - **SHAP feature chart** — render only if `shap_breakdown` field is non-null and non-empty in the API response
  - **Confidence indicator** — render only if `confidence_pct` is non-null
  - **Similar properties list** — render section only if `similar_properties` list is non-empty
  - **Market statistics** — render section only if `market_stats` is non-null
  - All conditional sections must gracefully collapse (not show empty containers) if absent
- Create `features/price_prediction/cubit/prediction_cubit.dart`
  - States: initial, formReady, loading, loaded(result), error
- Create `features/price_prediction/data/prediction_repository.dart`
- Create SHAP chart widget (feature-local, not in `core/`) — conditionally rendered

**Relevant Files:**
- `lib/features/price_prediction/`
- `docs/design_references/09_price_prediction.jpg`
- `docs/design_references/10_price_prediction_results.jpg`

**Dependencies (packages):**
- `fl_chart` — add only if the backend returns non-null `shap_breakdown` data confirmed from a live API call; defer until Phase 8 smoke test validates the response shape

**Testing Requirements:**
- Unit test: `PredictionCubit` all states
- Unit test: `PredictionRepository` with mocked API
- Unit test: form validation (required fields, numeric ranges)
- Widget test: form renders all fields, validates on submit
- Widget test: results screen shows price, chart, similar properties

**Acceptance Criteria:**
- Form screen matches `09_price_prediction.jpg`
- Results screen matches `10_price_prediction_results.jpg`
- Form validates inputs before submission
- Results display predicted price and price range unconditionally
- SHAP chart, confidence score, similar properties, and market stats are rendered **only when present in the API response** — missing fields collapse gracefully
- Loading and error states handled gracefully

**Definition of Done:** Prediction flow end-to-end, chart renders, results display complete, tests pass.

**Risks:**
- SHAP chart data format may vary — confirm with backend
- City-to-coordinates mapping needs a reliable source
- Prediction response time may be slow — add progress indicator

**Expected Deliverables:** `features/price_prediction/`, SHAP chart widget, cubit, repository, tests.

---

## Phase 11: AI Chat

**Objective:** Build the conversational AI chat interface with property card integration, connecting to `POST /api/chat`.

**Prerequisites:** Phase 8 complete; Phase 6 PropertyCard available.

**Tasks:**
- Create `features/ai_chat/presentation/chat_screen.dart`
  - Navy header
  - Scrollable message list (bottom-anchored)
  - User message bubbles (right, light background)
  - AI message bubbles (left, white/light)
  - Property cards rendered inline in AI responses
  - Category/suggestion chips (quick actions)
  - Text input bar with send button
- Create `features/ai_chat/presentation/widgets/chat_bubble.dart`
- Create `features/ai_chat/presentation/widgets/chat_input_bar.dart`
- Create `features/ai_chat/cubit/chat_cubit.dart`
  - States: initial, sending, messagesUpdated, error
  - Manage message list, session context
- Create `features/ai_chat/data/chat_repository.dart`
- Implement loading state (typing indicator) while AI responds
- Handle long responses (streaming if supported, or progressive display)
- Support sending property context ("Tell me about this property")

**Relevant Files:**
- `lib/features/ai_chat/`
- `docs/design_references/11_ai_chat.png`

**Dependencies (packages):** None new.

**Testing Requirements:**
- Unit test: `ChatCubit` send message, receive response, error handling
- Unit test: `ChatRepository` with mocked API
- Widget test: chat screen renders messages, input bar
- Widget test: property card renders inline in chat
- Widget test: typing indicator shows during loading

**Acceptance Criteria:**
- Chat screen matches `11_ai_chat.png`
- Messages display correctly with proper alignment
- AI responses with property data render PropertyCard widgets
- Input bar sends on tap and on keyboard submit
- Loading indicator shows while waiting for response
- Error messages shown on failure with retry

**Definition of Done:** Chat fully functional, messages persist in session, inline property cards work, tests pass.

**Risks:**
- LLM response latency may feel slow — consider streaming
- Chat responses may contain unpredictable formats — need robust parsing
- Session management (clear on logout, context window limits)

**Expected Deliverables:** `features/ai_chat/`, chat cubit, chat repository, chat widgets, tests.

---

## Phase 12: Settings and Account Management

**Objective:** Implement the Settings screen and account management flows: Edit Profile, Change Email, Change Password, Delete Account.

**Prerequisites:** Phase 4 (Auth) complete.

**Tasks:**
- Create `features/settings/presentation/settings_screen.dart`
  - Navy header
  - 4 rounded option cards with icons and chevrons:
    1. Edit Profile
    2. Change Email
    3. Change Password
    4. Delete Account (red accent)
- Create `features/settings/presentation/edit_profile_screen.dart`
  - Profile photo picker (camera / gallery) — optional, tap avatar circle to change
  - **Name field only** — editable
  - **Email field — read-only** (displayed for reference; changing email is a separate screen)
  - **No phone number field** — not present in the design reference (`16_edit_profile.png`) or Firebase Auth user model
  - Save button
- Create `features/settings/presentation/change_email_screen.dart`
  - Current email (read-only), new email field, password confirmation
  - Gold "Update" button
- Create `features/settings/presentation/change_password_screen.dart`
  - Current password, new password, confirm new password
  - Gold "Update" button
- Create `features/settings/presentation/delete_account_screen.dart`
  - Warning text, password confirmation (reauthentication)
  - Red "Delete Account" button
- Create `features/settings/cubit/settings_cubit.dart`
- Implement reauthentication flow for sensitive operations (change email, change password, delete account)
- Add `image_picker` for profile photo

**Relevant Files:**
- `lib/features/settings/`
- `docs/design_references/13_settings.png`
- `docs/design_references/14_change_email.png`
- `docs/design_references/15_change_password.png`
- `docs/design_references/16_edit_profile.png`

**Dependencies (packages):**
- `image_picker`
- `firebase_storage` (profile photo upload)

**Testing Requirements:**
- Unit test: `SettingsCubit` all operations (update profile, change email, change password, delete)
- Unit test: form validation for each sub-screen
- Widget test: settings screen renders 4 cards
- Widget test: each sub-screen renders correct fields
- Integration test: change password flow with reauthentication

**Acceptance Criteria:**
- Settings screen matches `13_settings.png`
- Edit Profile matches `16_edit_profile.png`
- Change Email matches `14_change_email.png`
- Change Password matches `15_change_password.png`
- Reauthentication required for sensitive operations
- Delete Account requires password confirmation and shows warning
- Success/error feedback on all operations

**Definition of Done:** All settings sub-screens functional, reauthentication works, tests pass.

**Risks:**
- Firebase reauthentication UX can be confusing
- Profile photo storage requires Firebase Storage setup
- Delete Account must clean up Firestore data (favourites)

**Expected Deliverables:** `features/settings/`, settings cubit, all sub-screens, tests.

---

## Phase 13: Testing and Optimization

**Objective:** Achieve target test coverage, run full static analysis, and optimise app performance.

**Prerequisites:** Phases 1–12 complete.

**Tasks:**
- Audit existing test coverage — identify gaps
- Write missing unit tests for all cubits (target ≥80% coverage)
- Write missing unit tests for all repositories (target ≥70% coverage)
- Write widget tests for every screen's key interactions
- Write integration tests:
  - Auth flow: register → login → home → logout
  - Favourites flow: browse → favourite → view favourites → unfavourite
  - Recommendation flow: open filters → set criteria → search → view results → view detail
  - Prediction flow: open form → fill inputs → calculate → view results
- Run `flutter analyze` — fix all warnings and errors
- Run `dart format` — ensure consistent formatting
- Profile app with DevTools:
  - Fix jank in scrollable lists (lazy loading, const constructors)
  - Optimise image caching (resize, thumbnails)
  - Reduce widget rebuilds (selective BlocBuilder, const widgets)
- Reduce app bundle size (tree-shake icons, deferred loading)
- Test on multiple screen sizes (phone, tablet)
- Test RTL layout thoroughly

**Relevant Files:**
- `test/` (entire directory)
- All `lib/` source files

**Dependencies (packages):**
- `mocktail` (mocking)
- `bloc_test` (cubit testing)
- `integration_test` (SDK)

**Testing Requirements:** This IS the testing phase — all test types listed above.

**Acceptance Criteria:**
- `flutter analyze` reports zero issues
- `dart format` reports no changes needed
- Cubit test coverage ≥80%
- Repository test coverage ≥70%
- All integration tests pass on a device/emulator
- No jank visible in scrollable lists (60fps target)
- App launches in <3 seconds on mid-range device

**Definition of Done:** Coverage targets met, zero static analysis issues, performance profiled and optimised.

**Risks:**
- Integration tests may be flaky on CI without a physical device
- Coverage targets may reveal poorly testable code requiring refactoring

**Expected Deliverables:** Comprehensive test suite, performance audit report, all fixes applied.

---

## Phase 14: Deployment and Release

**Objective:** Prepare the app for production deployment: host the backend, configure environments, generate release builds, and prepare store listings.

**Prerequisites:** Phase 13 complete.

**Tasks:**
- **Backend Hosting:**
  - Deploy Python FastAPI backend to hosting platform (Railway, Render, GCP Cloud Run, or AWS)
  - Configure environment variables (API keys, model paths)
  - Set up health check monitoring
  - Configure CORS for mobile client
  - Set up SSL/TLS
- **Environment Configuration:**
  - Create `core/constants/environment.dart` with dev / staging / prod configs
  - Configure base URLs per environment
  - Set up `--dart-define` or `.env` for build-time config
  - Remove all hardcoded dev URLs
- **Android Release:**
  - Generate signing keystore
  - Configure `android/app/build.gradle.kts` with release signing config
  - Set `applicationId` to final package name (replace `com.example.egy`)
  - Update `versionCode` and `versionName`
  - Configure ProGuard rules if needed
  - Build release APK and App Bundle: `flutter build appbundle --release`
  - Test release build on physical device
- **iOS Preparation (if applicable):**
  - Configure Bundle Identifier
  - Set up provisioning profiles and certificates
  - Configure capabilities (Push Notifications, Sign in with Apple)
  - Build and archive via Xcode
- **Store Listing Prep:**
  - Create app icon (from EGY logo)
  - Generate screenshots for required device sizes
  - Write store description (EN + AR)
  - Prepare privacy policy URL
  - Prepare terms of service URL
- **Final Checks:**
  - Full regression test on release build
  - Verify all API endpoints work in production environment
  - Verify Firebase Auth works with production config
  - Check app size is acceptable (<50MB target)

**Relevant Files:**
- `android/app/build.gradle.kts`
- `ios/Runner/Info.plist`
- `pubspec.yaml` (version)
- `lib/core/constants/environment.dart` (new)

**Dependencies:** Hosting platform account, Apple Developer account (iOS), Google Play Console account (Android).

**Testing Requirements:**
- Full integration test suite on release build
- Backend health check in production
- Smoke test all AI features against production backend
- Test on 3+ physical devices (different screen sizes)

**Acceptance Criteria:**
- Backend deployed and accessible via HTTPS
- Release APK installs and runs on physical device
- All features work end-to-end against production backend
- App bundle size <50MB
- No debug banners, logging, or dev endpoints in release

**Definition of Done:** Backend deployed, release build generated, store listing prepared, all smoke tests pass.

**Risks:**
- Backend hosting costs (ML models may need GPU or significant RAM)
- API key exposure in mobile app — use Firebase ID token auth
- Store review may flag AI-generated content
- Large model files may cause slow cold starts on hosting

**Expected Deliverables:** Deployed backend, signed release APK/AAB, store listing assets, environment configs.

---

## Roadmap Summary

| Phase | Name | Key Deliverable | Status |
|-------|------|----------------|--------|
| 0 | Repository Audit & Documentation | docs/, rules | ✅ Complete |
| 1 | Architecture Foundation | lib/app/, lib/core/, DI | ⬜ Pending |
| 2 | Design System & Navigation | Widgets, Router, i18n | ⬜ Pending |
| 3 | Splash & Onboarding | Splash, 3-page onboarding | ⬜ Pending |
| 4 | Firebase Authentication | Login, Register, Forgot Password | ⬜ Pending |
| 5 | Home & Navigation Drawer | Home screen, Drawer | ⬜ Pending |
| 6 | Property Listings & Details | Cards, Detail page, Gallery | ⬜ Pending |
| 7 | Favorites | Firestore persistence, list | ⬜ Pending |
| 8 | AI Backend Preparation | HTTP client, API service, models | ⬜ Pending |
| 9 | AI Recommendations | Filters, results | ⬜ Pending |
| 10 | Price Prediction | Form, results, SHAP chart | ⬜ Pending |
| 11 | AI Chat | Chat UI, inline property cards | ⬜ Pending |
| 12 | Settings & Account Management | Profile, email, password, delete | ⬜ Pending |
| 13 | Testing & Optimization | Coverage, performance | ⬜ Pending |
| 14 | Deployment & Release | Backend hosting, store prep | ⬜ Pending |

> **Parallelism Note:** Phase 8 (AI Backend Preparation) can begin as early as Phase 1 completion and proceed in parallel with Phases 5–7, as it has no UI dependencies.
