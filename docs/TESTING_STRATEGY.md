# EGY DEVELOPMENT — Testing Strategy

> [!NOTE]
> Testing is introduced incrementally alongside implementation phases.
> Every new Cubit, Repository, and core utility must have unit tests before the feature is marked complete.

---

## 1. Testing Philosophy

| Principle | Detail |
|---|---|
| Test behavior, not implementation | Test what the code does, not how it does it |
| Incremental coverage | Write tests as features are built, not at the end |
| Fast feedback | Unit tests run in milliseconds; no real Firebase or HTTP in unit tests |
| Realistic integration | Integration tests use the real app on a device or emulator |
| Mocking library | `mocktail` (not `mockito` — no code generation required) |

---

## 2. Testing Pyramid

```
         ┌─────────────────┐
         │  Integration     │  ← Few, slow, high confidence
         │  (device/emu)   │
         ├─────────────────┤
         │  Widget Tests    │  ← Medium, fast, UI verification
         │                 │
         ├─────────────────┤
         │  Unit Tests      │  ← Many, fastest, logic verification
         │  (Cubits, Repos) │
         └─────────────────┘
```

---

## 3. Unit Tests

### What to Unit Test

| Target | Test File Location | Priority |
|---|---|---|
| All Cubits | `test/features/<feature>/cubit/<name>_cubit_test.dart` | 🔴 Required |
| All Repository Impls | `test/features/<feature>/data/<name>_repository_test.dart` | 🔴 Required |
| Form validators | `test/core/utils/validators_test.dart` | 🔴 Required |
| Data model fromJson/toJson | `test/features/<feature>/data/models/<name>_model_test.dart` | 🟡 Recommended |
| Failure classes | `test/core/errors/failures_test.dart` | 🟢 Optional |
| Extension methods | `test/core/utils/extensions_test.dart` | 🟢 Optional |

### Cubit Test Pattern

```dart
// test/features/authentication/cubit/auth_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late AuthCubit cubit;

  setUp(() {
    mockRepo = MockAuthRepository();
    cubit = AuthCubit(authRepository: mockRepo);
  });

  tearDown(() => cubit.close());

  group('AuthCubit - signInWithEmail', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password123';
    final tUser = AppUser(id: '1', email: tEmail, name: 'Test User');

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        when(() => mockRepo.signInWithEmail(email: tEmail, password: tPassword))
            .thenAnswer((_) async => tUser);
        return cubit;
      },
      act: (c) => c.signInWithEmail(email: tEmail, password: tPassword),
      expect: () => [const AuthLoading(), AuthAuthenticated(user: tUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockRepo.signInWithEmail(email: tEmail, password: tPassword))
            .thenThrow(const AuthFailure(message: 'Invalid credentials'));
        return cubit;
      },
      act: (c) => c.signInWithEmail(email: tEmail, password: tPassword),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );
  });
}
```

### Repository Test Pattern

```dart
// test/features/price_prediction/data/prediction_repository_test.dart
class MockPredictionDatasource extends Mock implements PredictionRemoteDatasource {}

void main() {
  late MockPredictionDatasource mockDatasource;
  late PredictionRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockPredictionDatasource();
    repository = PredictionRepositoryImpl(datasource: mockDatasource);
  });

  group('PredictionRepository - predict', () {
    test('returns prediction result on successful API call', () async {
      // arrange
      final tRequest = PredictionRequest(size: 150, bedrooms: 3, ...);
      final tResponse = PredictionResponse(predictedPrice: 2500000, ...);
      when(() => mockDatasource.predict(tRequest)).thenAnswer((_) async => tResponse);

      // act
      final result = await repository.predict(tRequest);

      // assert
      expect(result, equals(tResponse));
    });
  });
}
```

---

## 4. Widget Tests

### What to Widget Test

| Target | Priority |
|---|---|
| Core reusable widgets (`EgyButton`, `EgyTextField`, `EgyCard`) | 🔴 Required |
| Form validation UI feedback | 🔴 Required |
| Cubit-driven state rendering (Loading, Error, Empty, Success) | 🟡 Recommended |
| Localization string rendering | 🟡 Recommended |
| RTL layout correctness | 🟡 Recommended |

### Widget Test Pattern

```dart
// test/core/widgets/egy_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EgyButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EgyButton(label: 'Log In', onTap: null),
          ),
        ),
      );
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading=true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EgyButton(label: 'Log In', onTap: null, isLoading: true),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Log In'), findsNothing);
    });
  });
}
```

### Cubit-Driven Widget Test Pattern

```dart
testWidgets('shows error message on AuthError state', (tester) async {
  final mockCubit = MockAuthCubit();
  whenListen(
    mockCubit,
    Stream.fromIterable([const AuthError(message: 'Invalid credentials')]),
    initialState: const AuthInitial(),
  );

  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: mockCubit,
      child: const MaterialApp(home: LoginPage()),
    ),
  );
  await tester.pump();

  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

---

## 5. Integration Tests

> [!IMPORTANT]
> Integration tests run on a real device or emulator. They are slow but verify the full user journey.
> Place integration tests in `integration_test/` at the project root.

### What to Integration Test

| Journey | Priority |
|---|---|
| Email login → Home screen | 🔴 Required |
| Register new user | 🔴 Required |
| Price prediction form → result | 🟡 Recommended |
| AI chat message send/receive | 🟡 Recommended |
| Favorites add/remove | 🟡 Recommended |
| Language switch EN ↔ AR | 🟡 Recommended |

### Integration Test Pattern

```dart
// integration_test/auth_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:egy/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can log in with valid credentials', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate past splash/onboarding if shown
    // Enter credentials
    await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'validPassword123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Assert home screen is shown
    expect(find.byKey(const Key('home_screen')), findsOneWidget);
  });
}
```

---

## 6. Backend API Tests

> [!NOTE]
> The Python AI backend has its own test suite. Flutter integration relies on mock datasources in unit tests
> and real backend calls only in integration tests (use a dedicated test environment).

### Flutter-Side API Mocking

For every `RemoteDatasource`, create a `MockRemoteDatasource` using `mocktail`:

```dart
class MockPropertyRemoteDatasource extends Mock implements PropertyRemoteDatasource {}
```

Use in Cubit and Repository unit tests to simulate API responses and errors.

### Python Backend Testing (Separate)

The backend should expose `/api/health` and test endpoints under `pytest`. See `EGY_DEVELOPMENT_ai/` for the backend test setup.

---

## 7. Required Test Dependencies

Add these to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  bloc_test: ^9.0.0
  mocktail: ^1.0.0
  fake_async: ^1.3.0
```

---

## 8. Coverage Targets

| Layer | Target Coverage |
|---|---|
| Cubits | ≥ 90% |
| Repositories | ≥ 80% |
| Core utilities & validators | ≥ 90% |
| Data models (fromJson/toJson) | ≥ 80% |
| Widgets (core reusable) | ≥ 70% |
| Integration journeys | Key paths covered |

> [!TIP]
> Run coverage with: `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`

---

## 9. Test File Structure

```
test/
├── core/
│   ├── utils/
│   │   ├── validators_test.dart
│   │   └── extensions_test.dart
│   └── widgets/
│       ├── egy_button_test.dart
│       ├── egy_text_field_test.dart
│       └── egy_card_test.dart
│
├── features/
│   ├── authentication/
│   │   ├── cubit/
│   │   │   └── auth_cubit_test.dart
│   │   ├── data/
│   │   │   ├── auth_repository_test.dart
│   │   │   └── models/
│   │   │       └── user_model_test.dart
│   │   └── presentation/
│   │       └── login_page_test.dart
│   │
│   ├── price_prediction/
│   │   ├── cubit/
│   │   │   └── prediction_cubit_test.dart
│   │   └── data/
│   │       └── prediction_repository_test.dart
│   │
│   ├── recommendations/
│   │   ├── cubit/
│   │   │   └── recommendation_cubit_test.dart
│   │   └── data/
│   │       └── recommendation_repository_test.dart
│   │
│   └── ai_chat/
│       ├── cubit/
│       │   └── chat_cubit_test.dart
│       └── data/
│           └── chat_repository_test.dart
│
└── helpers/
    ├── test_helpers.dart      # Common mock setup utilities
    └── mock_data.dart         # Sample JSON responses for tests

integration_test/
├── auth_flow_test.dart
├── prediction_flow_test.dart
└── chat_flow_test.dart
```

---

## 10. CI/CD Testing (Future)

When CI is configured:

1. Run `flutter analyze` — zero warnings policy
2. Run `flutter test` — all unit and widget tests must pass
3. Run `flutter test --coverage` — verify coverage thresholds
4. Run integration tests on Firebase Test Lab (Android) and Simulator

---

*Last updated: 2026-11-17 — Initial testing strategy*
