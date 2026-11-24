# EGY DEVELOPMENT — Architecture Guide

> **Version:** 1.1  
> **Last Updated:** 2026-11-18  
> **Pattern:** MVVM + Feature-First + Cubit + Repository  
> **Reference:** [hossamelshafay/ConnectHub](https://github.com/hossamelshafay/ConnectHub)

---

## 1. Architecture Overview

The app follows a **pragmatic Clean Architecture** using **Feature-First MVVM** with **Cubit** for state management and the **Repository Pattern** for data access.

```
┌─────────────────────────────────────────────┐
│                 Presentation                 │
│         (Screens, Widgets, Cubits)          │
├─────────────────────────────────────────────┤
│              Domain (optional)              │
│          (Entities, Use Cases)              │
├─────────────────────────────────────────────┤
│                   Data                       │
│     (Repositories, Data Sources, DTOs)      │
├─────────────────────────────────────────────┤
│               Core / Shared                  │
│    (Network, Storage, Theme, Widgets)       │
└─────────────────────────────────────────────┘
```

### When to Use the Domain Layer

| Scenario | Use Domain Layer? |
|---|---|
| Simple CRUD (favorites, settings) | ❌ Repository → Cubit directly |
| Complex business logic (price prediction validation, recommendation filtering) | ✅ Use Cases |
| Data from multiple repositories | ✅ Use Cases to orchestrate |
| Logic that must be unit-tested in isolation | ✅ Use Cases |

> [!TIP]
> Start without a domain layer for simple features. Extract Use Cases only when business logic grows beyond what a Cubit should own.

---

## 2. Folder Structure

```
lib/
├── app/
│   ├── app.dart                        # MaterialApp.router with theme + localization
│   ├── router/
│   │   ├── app_router.dart             # GoRouter configuration
│   │   ├── route_names.dart            # Named route constants
│   │   └── route_guards.dart           # Auth redirect logic
│   ├── theme/
│   │   ├── app_theme.dart              # ThemeData (light + dark stubs)
│   │   ├── app_colors.dart             # Color constants
│   │   ├── app_text_styles.dart        # TextStyle definitions
│   │   └── app_dimensions.dart         # Spacing, radius, sizing constants
│   ├── localization/
│   │   ├── app_localizations.dart      # Generated (flutter gen-l10n)
│   │   ├── arb/
│   │   │   ├── app_en.arb
│   │   │   └── app_ar.arb
│   │   └── l10n.dart                   # Locale config helper
│   └── di/
│       ├── injection.dart              # GetIt setup + initialization
│       └── injection.config.dart       # Generated (injectable)
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart          # Base URL, endpoint paths
│   │   ├── app_constants.dart          # App-wide magic values
│   │   └── asset_paths.dart            # Asset string constants
│   ├── errors/
│   │   ├── failures.dart               # Failure sealed class
│   │   ├── exceptions.dart             # Custom exceptions
│   │   └── error_handler.dart          # Global error → Failure mapper
│   ├── network/
│   │   ├── api_client.dart             # Dio instance + interceptors
│   │   ├── api_interceptor.dart        # Auth token, logging, error interceptors
│   │   └── network_info.dart           # Connectivity checker
│   ├── storage/
│   │   ├── local_storage.dart          # SharedPreferences wrapper
│   │   └── secure_storage.dart         # flutter_secure_storage wrapper
│   ├── services/
│   │   └── firebase_service.dart       # Firebase initialization helper
│   ├── widgets/
│   │   ├── app_header.dart             # Reusable navy header with back button
│   │   ├── primary_button.dart         # Contextual button — color driven by theme token, NOT always gold
│   │   ├── secondary_button.dart       # Outlined navy button
│   │   ├── app_text_field.dart         # Styled text input
│   │   ├── property_card.dart          # Property listing card
│   │   ├── loading_indicator.dart      # Shimmer / spinner
│   │   ├── error_view.dart             # Error state widget
│   │   ├── empty_view.dart             # Empty state widget
│   │   └── cached_image.dart           # CachedNetworkImage wrapper
│   └── utils/
│       ├── extensions.dart             # String, BuildContext extensions
│       ├── validators.dart             # Form validation helpers
│       └── formatters.dart             # Currency, date formatters
│
├── features/
│   ├── splash/                                 # Standalone animated brand introduction
│   │   └── presentation/                       # Pure presentation — no data/ or domain/ layer
│   │       ├── pages/
│   │       │   └── splash_page.dart            # SplashPage + SplashPageWrapper
│   │       ├── widgets/
│   │       │   └── cairo_skyline_painter.dart  # CairoSkylinePainter (CustomPainter, Astra-generated)
│   │       └── cubit/
│   │           └── splash_cubit.dart           # SplashCubit + SplashState (sealed) + SplashDestination
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── onboarding_page.dart
│   │       ├── widgets/
│   │       │   └── onboarding_assets.dart
│   │       └── cubit/
│   │           └── onboarding_cubit.dart
│   │
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── data_sources/
│   │   │   │   └── firebase_auth_data_source.dart
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart       # Abstract interface
│   │   │   └── entities/
│   │   │       └── user_entity.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── forgot_password_screen.dart
│   │       ├── widgets/
│   │       │   ├── auth_header.dart
│   │       │   └── social_login_button.dart
│   │       └── cubit/
│   │           ├── auth_cubit.dart
│   │           └── auth_state.dart
│   │
│   ├── home/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── home_repository_impl.dart
│   │   │   ├── data_sources/
│   │   │   │   └── home_remote_data_source.dart
│   │   │   └── models/
│   │   │       └── featured_property_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       ├── widgets/
│   │       │   ├── home_header.dart
│   │       │   ├── category_chips.dart
│   │       │   └── featured_section.dart
│   │       └── cubit/
│   │           ├── home_cubit.dart
│   │           └── home_state.dart
│   │
│   ├── property_search/
│   │   └── ...                               # Same pattern
│   │
│   ├── property_details/
│   │   └── ...
│   │
│   ├── recommendations/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── recommendations_repository_impl.dart
│   │   │   ├── data_sources/
│   │   │   │   └── recommendations_remote_data_source.dart
│   │   │   └── models/
│   │   │       ├── recommendation_filter_model.dart
│   │   │       └── recommendation_result_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── recommendation_filters_screen.dart
│   │       │   └── recommendation_results_screen.dart
│   │       ├── widgets/
│   │       │   ├── filter_chip_group.dart
│   │       │   └── recommendation_card.dart
│   │       └── cubit/
│   │           ├── recommendations_cubit.dart
│   │           └── recommendations_state.dart
│   │
│   ├── price_prediction/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── prediction_repository_impl.dart
│   │   │   ├── data_sources/
│   │   │   │   └── prediction_remote_data_source.dart
│   │   │   └── models/
│   │   │       ├── prediction_request_model.dart
│   │   │       └── prediction_result_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── prediction_input_screen.dart
│   │       │   └── prediction_result_screen.dart
│   │       ├── widgets/
│   │       │   ├── prediction_form.dart
│   │       │   └── price_display_card.dart
│   │       └── cubit/
│   │           ├── prediction_cubit.dart
│   │           └── prediction_state.dart
│   │
│   ├── ai_chat/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository_impl.dart
│   │   │   ├── data_sources/
│   │   │   │   └── chat_remote_data_source.dart
│   │   │   └── models/
│   │   │       └── chat_message_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── ai_chat_screen.dart
│   │       ├── widgets/
│   │       │   ├── chat_bubble.dart
│   │       │   ├── chat_input_bar.dart
│   │       │   └── typing_indicator.dart
│   │       └── cubit/
│   │           ├── chat_cubit.dart
│   │           └── chat_state.dart
│   │
│   ├── favorites/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository_impl.dart
│   │   │   └── data_sources/
│   │   │       ├── favorites_firestore_data_source.dart  # Source of truth for authenticated users
│   │   │       └── favorites_local_cache.dart            # Optional read-through cache (SharedPreferences only — no Hive)
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── favorites_screen.dart
│   │       └── cubit/
│   │           ├── favorites_cubit.dart
│   │           └── favorites_state.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── screens/
│           │   ├── settings_screen.dart
│           │   ├── edit_profile_screen.dart
│           │   ├── change_email_screen.dart
│           │   └── change_password_screen.dart
│           ├── widgets/
│           │   └── settings_tile.dart
│           └── cubit/
│               ├── settings_cubit.dart
│               └── settings_state.dart
│
└── main.dart                                  # Entry point: WidgetsFlutterBinding, Firebase.initializeApp, runApp
```

---

## 3. Layer Responsibilities

### Presentation Layer

| Component | Responsibility |
|---|---|
| **Screen** | Builds the UI tree; listens to Cubit via `BlocBuilder`/`BlocListener`. Contains zero business logic. |
| **Widget** | Reusable UI piece extracted from a screen. Receives data via constructor; fires callbacks. |
| **Cubit** | Holds state; exposes methods the screen calls. Delegates data work to Repositories. Emits new states. |
| **State** | Immutable data class (using `Equatable`) representing the UI state at a point in time. |

### Data Layer

| Component | Responsibility |
|---|---|
| **Repository Impl** | Implements the domain/abstract repository. Chooses between remote and local data sources. Maps DTOs → Entities. Handles errors → Failures. |
| **Remote Data Source** | Calls the Python AI backend via Dio. Returns raw DTOs. Throws exceptions on HTTP errors. |
| **Local Data Source** | Reads/writes Hive boxes or SharedPreferences. Returns raw DTOs. |
| **Model / DTO** | JSON-serializable data class with `fromJson`/`toJson`. Maps to/from domain entities. |

### Domain Layer (Optional per Feature)

| Component | Responsibility |
|---|---|
| **Entity** | Pure Dart class representing a business concept. No framework dependencies. |
| **Repository (abstract)** | Interface that the data layer implements. Defined in domain so presentation depends only on the abstraction. |
| **Use Case** | Single-responsibility class encapsulating one business operation. Calls one or more repositories. |

---

## 4. Cubit Pattern

### State Design

Every feature state follows this sealed-class pattern:

```dart
// features/recommendations/presentation/cubit/recommendations_state.dart

import 'package:equatable/equatable.dart';

sealed class RecommendationsState extends Equatable {
  const RecommendationsState();

  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {}

class RecommendationsLoading extends RecommendationsState {}

class RecommendationsSuccess extends RecommendationsState {
  final List<RecommendationEntity> results;
  final bool hasMore;

  const RecommendationsSuccess({
    required this.results,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [results, hasMore];
}

class RecommendationsEmpty extends RecommendationsState {}

class RecommendationsError extends RecommendationsState {
  final String message;

  const RecommendationsError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### Cubit Design

```dart
// features/recommendations/presentation/cubit/recommendations_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

class RecommendationsCubit extends Cubit<RecommendationsState> {
  final RecommendationsRepository _repository;

  RecommendationsCubit(this._repository) : super(RecommendationsInitial());

  Future<void> search(RecommendationFilter filter) async {
    emit(RecommendationsLoading());
    final result = await _repository.search(filter);
    result.fold(
      (failure) => emit(RecommendationsError(failure.message)),
      (data) => data.isEmpty
          ? emit(RecommendationsEmpty())
          : emit(RecommendationsSuccess(results: data)),
    );
  }
}
```

> [!NOTE]
> Use `Either<Failure, T>` from `dartz` or `fpdart` for Result types in repositories. Alternatively, use a simple custom `Result<T>` sealed class to avoid a full FP dependency.

---

## 5. Repository Pattern

### Abstract Repository (Domain)

```dart
// features/price_prediction/domain/repositories/prediction_repository.dart

abstract class PredictionRepository {
  Future<Either<Failure, PredictionResult>> predict(PredictionRequest request);
}
```

### Concrete Repository (Data)

```dart
// features/price_prediction/data/repositories/prediction_repository_impl.dart

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDataSource _remoteDataSource;

  PredictionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PredictionResult>> predict(
    PredictionRequest request,
  ) async {
    try {
      final model = await _remoteDataSource.predict(request.toModel());
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(const NetworkFailure('No internet connection'));
    }
  }
}
```

### Remote Data Source

```dart
// features/price_prediction/data/data_sources/prediction_remote_data_source.dart

class PredictionRemoteDataSource {
  final ApiClient _client;

  PredictionRemoteDataSource(this._client);

  Future<PredictionResultModel> predict(PredictionRequestModel request) async {
    final response = await _client.post(
      ApiConstants.predict,
      data: request.toJson(),
    );
    return PredictionResultModel.fromJson(response.data);
  }
}
```

---

## 6. Dependency Injection

### Strategy: `get_it` with explicit manual registration

> [!IMPORTANT]
> Phase 1 uses **plain `get_it` with manual registration only**. Do NOT add `injectable` or `build_runner` until the codebase is large enough for code generation to earn its complexity cost. Re-evaluate at Phase 4 (Auth) or later. Keep the registration list visible and readable in a single file.

```dart
// app/di/injection.dart

final GetIt getIt = GetIt.instance;

// @InjectableInit annotation removed — use explicit registration below.
// Add injectable + build_runner only when manual registration becomes unwieldy (Phase 4+).
Future<void> setupDependencies() async => getIt.init();
```

### Registration Order

1. **External modules** — Dio, SharedPreferences, FirebaseAuth (registered as async singletons)
2. **Data Sources** — Remote and local (singletons)
3. **Repositories** — Implementations bound to abstract interfaces (singletons)
4. **Cubits** — Registered as factories (new instance per screen)

```dart
// Example manual registration (if not using injectable code-gen):

void setupDependencies() {
  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Price Prediction
  getIt.registerLazySingleton<PredictionRemoteDataSource>(
    () => PredictionRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<PredictionRepository>(
    () => PredictionRepositoryImpl(getIt()),
  );
  getIt.registerFactory<PredictionCubit>(
    () => PredictionCubit(getIt()),
  );
}
```

> [!IMPORTANT]
> Cubits must be registered as **factories**, not singletons. Each screen instance should get a fresh Cubit to avoid stale state.

---

## 7. Navigation Strategy

### go_router with ShellRoute for Drawer

```dart
// app/router/app_router.dart

final appRouter = GoRouter(
  initialLocation: '/splash',
  // redirect is ONLY used for auth-aware route protection (Phase 4+).
  // First-run routing (Splash → Onboarding vs Login) is owned by SplashCubit.
  routes: [
    // Unauthenticated routes
    GoRoute(path: '/splash', builder: (_, __) => const SplashPageWrapper()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

    // Authenticated routes wrapped in ShellRoute for the Drawer
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/recommendations', builder: (_, __) => const RecommendationFiltersScreen()),
        GoRoute(path: '/recommendations/results', builder: (_, __) => const RecommendationResultsScreen()),
        GoRoute(path: '/price-prediction', builder: (_, __) => const PredictionInputScreen()),
        GoRoute(path: '/price-prediction/results', builder: (_, __) => const PredictionResultScreen()),
        GoRoute(path: '/ai-chat', builder: (_, __) => const AiChatScreen()),
        GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/settings/edit-profile', builder: (_, __) => const EditProfileScreen()),
        GoRoute(path: '/settings/change-email', builder: (_, __) => const ChangeEmailScreen()),
        GoRoute(path: '/settings/change-password', builder: (_, __) => const ChangePasswordScreen()),
      ],
    ),
  ],
);
```

### Drawer-Based Navigation

The `AppShell` widget wraps all authenticated screens and provides the persistent `Drawer`:

```dart
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
```

The `AppDrawer` renders:
- Profile photo + name + email (top section, navy gradient background)
- Menu items: Home, Recommendations, Price Prediction, AI Chat, Favorites, Settings
- Logout button at bottom
- Gold accent icons

---

## 8. Network Layer

### Dio Configuration

```dart
// core/network/api_client.dart

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      ApiInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post(path, data: data);
}
```

### API Constants

```dart
// core/constants/api_constants.dart

// ⚠️  NEVER use 'localhost' or '127.0.0.1' as the backend URL for a physical device.
//     On Android, the emulator loopback is 10.0.2.2; on a physical device the
//     backend must be reachable via a LAN IP, ngrok tunnel, or a deployed HTTPS URL.
//
//     Provide the base URL at build time via --dart-define:
//       flutter run --dart-define=API_BASE_URL=https://your-backend.example.com
//
//     Do NOT hard-code any URL for production. See SECURITY.md §Environment Config.

class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000', // Android emulator loopback — dev only
  );

  // Chat
  static const String chat = '/api/chat';

  // Predictions
  static const String predict = '/api/predict';

  // Recommendations
  static const String recommendationsSearch = '/api/recommendations/search';
  static const String recommendationsSimilar = '/api/recommendations/similar';
  static const String recommendationsById = '/api/recommendations';
  static const String recommendationsBatch = '/api/recommendations/batch';
  static const String recommendationsFeatured = '/api/recommendations/featured/list';

  // Health
  static const String health = '/api/health';
}
```

---

## 9. Error Handling Strategy

### Failure Hierarchy

```dart
// core/errors/failures.dart

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

### Error Flow

```
Remote Data Source throws Exception
        ↓
Repository catches → returns Left(Failure)
        ↓
Cubit receives → emits ErrorState(failure.message)
        ↓
Screen renders ErrorView widget
```

---

## 10. Tradeoffs & Decisions

| Decision | Chosen | Alternative | Why |
|---|---|---|---|
| **Cubit over Bloc** | ✅ Cubit | Bloc (events) | Most screens are simple request→response. Bloc events add boilerplate without benefit here. Can upgrade individual Cubits to Bloc if event-driven logic needed. |
| **go_router over auto_route** | ✅ go_router | auto_route | Official Flutter-endorsed, simpler setup, good ShellRoute support for drawer. |
| **get_it over Riverpod** | ✅ get_it | Riverpod | Already using Cubit for state; Riverpod would be a competing state paradigm. get_it is a pure service locator. |
| **Feature-First over Layer-First** | ✅ Feature-First | Layer-First (`lib/data/`, `lib/domain/`, `lib/presentation/`) | Features are self-contained; easier to navigate, delete, or hand off to another developer. |
| **Optional domain layer** | ✅ Per-feature decision | Always domain layer | Avoids premature abstraction for simple CRUD features while allowing it for complex ones. |
| **dartz/fpdart Either** | ✅ Recommended | Custom Result class | Mature, well-tested. But a custom `Result<T>` sealed class is acceptable to reduce dependencies. |
| **Cairo font** | ✅ Cairo via google_fonts | System fonts | Best Arabic + Latin coverage in a single font family. google_fonts handles caching. |
| **SharedPreferences (no Hive)** | ✅ SharedPreferences | Hive, SQLite | SharedPreferences is sufficient for language/theme/onboarding flags. Hive adds code-gen overhead and binary format complexity; introduce it only if structured local caching of property lists becomes a verified requirement. Favorites are persisted in Firestore (not locally). |

---

## 11. File Size Guidelines

| Guideline | Rule |
|---|---|
| **Hard limit** | 400 lines per file |
| **Preferred range** | 100–250 lines |
| **Screen too large?** | Extract widgets into `widgets/` subfolder |
| **Cubit too large?** | Extract business logic into Use Cases (domain layer) |
| **Model too large?** | Split into sub-models or use `json_serializable` part files |

---

## 12. Testing Strategy

| Layer | Tool | Coverage Target |
|---|---|---|
| **Cubits** | `bloc_test` + `mocktail` | All state transitions |
| **Repositories** | `mocktail` | Error handling paths |
| **Widgets** | `flutter_test` | Key UI components |
| **Integration** | `integration_test` | Critical user journeys |

```dart
// Example Cubit test
blocTest<PredictionCubit, PredictionState>(
  'emits [Loading, Success] when predict succeeds',
  build: () {
    when(() => mockRepo.predict(any())).thenAnswer(
      (_) async => Right(mockResult),
    );
    return PredictionCubit(mockRepo);
  },
  act: (cubit) => cubit.predict(mockRequest),
  expect: () => [
    PredictionLoading(),
    PredictionSuccess(result: mockResult),
  ],
);
```


---

## 13. Splash & First-Run Routing

### Feature location

```
lib/features/splash/
└── presentation/        ← no data/ or domain/ — pure presentation feature
    ├── pages/
    │   └── splash_page.dart        # SplashPage (animated) + SplashPageWrapper (DI)
    ├── widgets/
    │   └── cairo_skyline_painter.dart   # CairoSkylinePainter (CustomPainter)
    └── cubit/
        └── splash_cubit.dart       # SplashCubit + SplashState (sealed) + SplashDestination
```

### Routing decision ownership

`SplashCubit` reads `SharedPreferences` (injected at construction via `RepositoryProvider` in `App`) and emits `SplashDone(destination: SplashDestination.onboarding | login)`. The router's `BlocListener` in `SplashPage` calls `context.go(...)` on that event.

> [!IMPORTANT]
> The GoRouter `redirect` callback is **reserved for auth-aware route protection (Phase 4+)**. It is NOT used for first-run routing. Using `redirect` for first-run logic forces an async `SharedPreferences` read on every navigation event and couples unrelated concerns to the router.

### Animation overview

- Single `AnimationController` over 3 000 ms with `SingleTickerProviderStateMixin`.
- `CairoSkylinePainter` renders a Cairo-inspired skyline (pyramids, mosque, towers, arcade) using per-frame opacity/offset math.
- Logo (`assets/img/logo.png`) fades in at the 1 900 ms mark.
- Entire scene fades out at 2 670 ms; `SplashCubit.onAnimationComplete()` is called at the end.
- `MediaQuery.disableAnimationsOf` is respected for accessibility.

### Color palette (painter-scoped, raw hex acceptable)

The `CairoSkylinePainter` is a pure `CustomPainter` graphic component with its own embedded palette. Raw hex constants inside `cairo_skyline_painter.dart` are acceptable and intentional; they do **not** violate the "no hardcoded colors in widget code" rule, which applies to UI widgets that should respect the app theme.

| Name | Hex |
|---|---|
| Ivory (background) | `#FAF7EF` |
| Navy | `#223C52` |
| Slate | `#758997` |
| Mist | `#B5C0BF` |
| Gold | `#C89E60` |
| Sand | `#DFC79F` |

### Tests

`test/features/splash/splash_cubit_test.dart` covers:
1. Initial state is `SplashAnimating`.
2. Routes to `onboarding` when `SharedPreferences` has no `onboarding_done` key.
3. Routes to `login` when `onboarding_done` is `true`.
4. Double-call to `onAnimationComplete()` does not emit duplicate states.
