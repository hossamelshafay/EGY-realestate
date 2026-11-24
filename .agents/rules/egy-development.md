# EGY DEVELOPMENT — Project Rules

> These rules apply to every development session for the EGY DEVELOPMENT Flutter project.
> They are binding and must be followed by all agents and developers.
> Last updated: 2026-11-17

---

## 1. Project Identity

- Project name: **EGY DEVELOPMENT**
- Type: AI-powered Egyptian real estate mobile app
- Flutter workspace: `d:\flutter\egy-ai\egy`
- Python AI backend: `d:\flutter\egy-ai\egy\EGY_DEVELOPMENT_ai\`
- Firebase project: `real-estate-e1418`
- Current Flutter package name: `com.example.egy` (pending owner decision to rename)

---

## 2. Architecture Rules

### 2.1 Pattern

- Architecture is **Feature-First + MVVM + Cubit + Repository Pattern**.
- Never deviate from this pattern without explicit owner approval.
- Do NOT introduce BLoC (use Cubit only).
- Do NOT use Provider, Riverpod, or MobX.
- Do NOT use setState for feature-level state — Cubit only.

### 2.2 Feature Structure

Every feature lives in `lib/features/<feature_name>/` and uses:
```
<feature>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

Do NOT create empty folders. Only create directories that contain actual files.

Do NOT create `domain/usecases/` unless real business logic justifies a Use Case class.

**Currently implemented features and their layers:**

| Feature | data/ | domain/ | presentation/ |
|---|---|---|---|
| `splash` | ❌ (pure presentation) | ❌ | ✅ cubit, pages, widgets |
| `onboarding` | ❌ | ❌ | ✅ cubit, pages, widgets |
| `authentication` | future | future | future (Phase 4) |

> **Splash** is a standalone feature with no `data/` layer. `SplashCubit` reads `SharedPreferences` passed to it at construction (via `RepositoryProvider` in `App`) to determine the initial destination. It does **not** use a GoRouter `redirect` for this logic — that pattern is reserved for auth-aware redirects in Phase 4+.

**Reference architecture:** [hossamelshafay/ConnectHub](https://github.com/hossamelshafay/ConnectHub). EGY follows the same feature-first principles but uses `pages/` (not `views/`) and `cubit/` (not `manager/cubit/`) to match EGY's existing established convention.

### 2.3 Cubit Rules

- All Cubit states are **sealed classes** with named subclasses.
- All state fields are **final** (immutable).
- Never call `Navigator` or `context` from a Cubit.
- Never hold `BuildContext` in a Cubit.
- State pattern: `Initial → Loading → Success | Error | Empty`

### 2.4 Repository Rules

- Repository **interfaces** go in `domain/repositories/`.
- Repository **implementations** go in `data/repositories/`.
- Repositories return domain **entities**, not raw HTTP models.
- Repositories catch all exceptions and convert to **Failure** types.
- Presentation layer never touches Firebase or HTTP directly.

### 2.5 Dependency Injection

- Use `get_it` service locator.
- Register singletons for: repositories, datasources, services, API client.
- Register factories for: Cubits (new instance per navigation).
- All DI registration happens in `lib/app/di/injection.dart` before `runApp()`.

---

## 3. UI Rules

### 3.1 Navigation

- Navigation uses **Drawer only** (no Bottom Navigation Bar unless owner approves).
- Routing is implemented with `go_router`.
- **Auth-aware redirects** (Phase 4+) belong in the GoRouter `redirect` callback, not in widgets.
- **First-run routing** (Splash → Onboarding vs Login) is owned by `SplashCubit`, not by a router redirect.
- Protected routes are wrapped in a `ShellRoute` with `DrawerScaffold`.

### 3.2 Design System

- **ALL colors** must use semantic tokens from `lib/app/theme/app_colors.dart`.
- **NO hardcoded hex colors** anywhere in widget code.
- **NO hardcoded text styles** — use `Theme.of(context).textTheme.*` or named styles.
- Color palette:
  - Navy: `#031A2D` — headers, drawer
  - Gold: `#E5A11A` — active chips, logo accent, some CTA buttons
  - White: `#FFFFFF` — content panels
  - Off-White: `#F7F8FA` — input backgrounds
  - Destructive Red: `#E53935` — delete actions
- **Button colors are NOT universally gold.** Always check the design reference image for the specific screen before choosing a button color. The login screen may use a blue primary button. Use the correct semantic color token from `AppColors` for each button.
- Layout pattern: **Navy gradient header → White rounded panel** (24px top radius).
- Use **4px spacing grid**: multiples of 4 for all padding/margin/spacing.

### 3.3 Logo

- The EGY logo is a **custom branded asset** (gold serif text + swoosh underline).
- **NEVER** recreate the logo with a `Text` widget.
- Always render via `Image.asset('assets/images/egy_logo.svg')` or similar.
- Do not proceed with Splash or Drawer implementation until the owner provides the logo asset.

### 3.4 Language & RTL

- ALL visible strings must be in localization ARB files (`app_en.arb`, `app_ar.arb`).
- **NO hardcoded strings** in widget code (except temporary placeholders marked with `// TODO: l10n`).
- Arabic locale must use `Cairo` font family.
- RTL layout must be tested for every screen before the screen is marked complete.
- Use `Directionality` and `TextAlign.start` (never `.left`/`.right`) for locale-aware alignment.

### 3.5 Theme Mode

- Light Mode is the **only currently approved mode**.
- Dark Mode must be **architecturally supported** (ThemeData dark scaffold exists) but not implemented.
- Do NOT implement dark-mode-specific widgets or colors until the owner approves a Dark Mode phase.

### 3.6 Responsiveness

- Target: mobile-first (360dp–414dp width).
- Layouts must not break on tablets (600dp+).
- Use `LayoutBuilder` or `MediaQuery` for responsive adjustments.
- Do not use fixed pixel widths for full-width containers — use `double.infinity` or `fraction * constraints.maxWidth`.

---

## 4. Code Quality Rules

### 4.1 File Length

| File Type | Absolute Max | Preferred |
|---|---|---|
| Pages | 400 lines | 150-250 |
| Widgets | 200 lines | 50-150 |
| Cubits | 150 lines | 50-100 |
| States | 60 lines | 20-40 |
| Repositories | 200 lines | 80-150 |

If a file approaches its limit, extract sub-widgets or split responsibilities.

### 4.2 Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `camelCase` (never `SCREAMING_SNAKE_CASE`)
- Private members: prefix `_`
- Widget keys: `const Key('descriptive_name')`

### 4.3 Widget Guidelines

- Prefer `StatelessWidget` over `StatefulWidget`.
- Use `StatefulWidget` only for local ephemeral state (animations, `TextEditingController`, `FocusNode`).
- Extract named widgets instead of nesting closures.
- Always name key widgets with `const Key(...)` for testability.

### 4.4 Imports

Group in this order (separated by blank lines):
1. `dart:*` packages
2. `package:flutter/*` packages
3. Third-party pub packages
4. Project imports (`package:egy/*`)

Use relative imports **within** a feature; absolute `package:egy/` imports **across** features.

### 4.5 Analysis

- Run `flutter analyze` with zero warnings before every commit.
- `analysis_options.yaml` must enforce strict lints.
- No `// ignore:` comments unless absolutely justified and documented.
- No unused imports, variables, or parameters.

### 4.6 Comments

- Document all public APIs with doc comments (`///`).
- Explain complex logic inline.
- No `// TODO` left unresolved before marking a feature complete.
- No commented-out code committed to version control.

---

## 5. Firebase Rules

- Firebase project ID: `real-estate-e1418` — do NOT create a new project.
- Do NOT run `flutterfire configure` — config already exists.
- Do NOT overwrite `firebase_options.dart`.
- Do NOT modify Firebase Console settings without owner approval.
- Do NOT create production Firestore collections during development — use test collections.
- Authentication providers to implement: Email/Password, Google, Apple.
  - Confirm Google and Apple are enabled in Firebase Console before coding.
- Never expose Firebase secrets or API keys in documentation or logs.
- Security rules must deny unauthenticated reads/writes for all production collections.

---

## 6. Python AI Backend Rules

- The Python backend lives at `EGY_DEVELOPMENT_ai/` — do NOT move, rename, or restructure it.
- Do NOT modify Python source code or model files during Flutter implementation phases.
- Do NOT retrain or replace AI models.
- Flutter communicates with the backend via HTTP (Dio) only.
- All API calls go through the Repository → Datasource layer.
- Never call the Python backend directly from a Cubit or widget.
- Respect the AI endpoint timeouts: predict/recommend = 30s, chat = 60s.
- **`localhost` / `127.0.0.1` is NEVER a valid backend URL for a physical device.** Use `10.0.2.2` for the Android emulator, the host LAN IP or ngrok for physical devices, and a deployed HTTPS URL in production. Supply via `--dart-define=API_BASE_URL=...`.
- **Backend security: attaching a Firebase ID token in the Flutter `Authorization` header is necessary but NOT sufficient.** The Python backend must independently verify the token using the Firebase Admin SDK on every request before production. Without server-side verification, the backend accepts any caller.
- The `scikit-learn` version in `requirements.txt` is pinned to `==1.9.1`. Verify this resolves to a valid pip package and matches the joblib artifact version before assuming the backend boots correctly.

---

## 7. Security Rules

- Never commit `.env` files or secrets.
- Never log authentication tokens or sensitive user data.
- Use `flutter_secure_storage` for auth tokens — never `SharedPreferences` for secrets.
- CORS on the Python backend must be restricted to the deployed app URL before production.
- Python API endpoints must verify Firebase ID tokens **server-side** before production deployment.
- Attaching the token on the Flutter client alone is NOT sufficient security.
- Account deletion must delete both Firebase Auth user and all Firestore user data.

---

## 8. Process Rules

### 8.1 Planning Before Coding

- Read the relevant documentation in `docs/` before starting any feature.
- Confirm the design reference image exists in `docs/design_references/` before building a screen.
- Check open questions in `docs/MASTER_PLAN.md` Section 6 before making blocking decisions.

### 8.2 Phase Discipline

- Implement one phase at a time (see `docs/DEVELOPMENT_ROADMAP.md`).
- Do not start Phase N+1 before Phase N acceptance criteria are met.
- Do not implement Dark Mode, Web, or Desktop until the owner approves.

### 8.3 Testing Discipline

- Every new Cubit must have a unit test before the feature is marked complete.
- Every new Repository must have a unit test before the feature is marked complete.
- Core reusable widgets must have widget tests.
- Tests live in `test/` mirroring the `lib/` structure.
- Use `mocktail` for mocking — not `mockito`.

### 8.4 Documentation Updates

- Update `docs/MASTER_PLAN.md` at the start of each phase.
- Update `docs/DEVELOPMENT_ROADMAP.md` when a phase is completed.
- Document any new API endpoints discovered in `docs/API_CONTRACTS.md`.
- Document any Firebase schema changes in `docs/FIREBASE.md`.

### 8.5 Owner Approval Gates

These actions require explicit owner approval before proceeding:
- Changing the Flutter package name
- Enabling new Firebase Auth providers
- Changing Firebase security rules
- Modifying the Python AI backend
- Implementing Dark Mode
- Adding major new dependencies not in `docs/ARCHITECTURE.md`
- Deploying to production or app stores

---

## 9. What NOT To Do

> [!CAUTION]
> These actions are explicitly prohibited:

- Do NOT use `setState` for feature-level state management
- Do NOT hardcode colors — use theme tokens
- Do NOT hardcode strings — use localization
- Do NOT put business logic in widgets or pages
- Do NOT call Firebase or HTTP directly from Cubits
- Do NOT create empty placeholder directories or files — only create a directory when it will immediately contain at least one source file
- Do NOT use `dynamic` types in production code
- Do NOT suppress lint warnings without documented justification
- Do NOT commit code that fails `flutter analyze`
- Do NOT move or rename the `EGY_DEVELOPMENT_ai/` directory
- Do NOT overwrite `firebase_options.dart`
- Do NOT use Bottom Navigation Bar (Drawer is the approved navigation pattern)
- Do NOT recreate the EGY logo with a Text widget
- Do NOT add a phone number field to Edit Profile — the approved screen contains name + read-only email + optional profile photo only
- Do NOT use Hive for Favorites — Firestore is the source of truth; SharedPreferences may be used for lightweight caching if justified
- Do NOT use `localhost` or `127.0.0.1` as the backend base URL — it is unreachable on physical devices
- Do NOT assume all primary buttons are gold — check each screen's design reference before assigning button color
- Do NOT add `injectable` or `build_runner` to Phase 1 — start with plain `get_it` manual registration
- Do NOT describe the Python backend as "production-ready" — it is code-complete; production readiness requires deployment, auth, CORS restriction, and smoke tests
- Do NOT place feature files in `lib/` root — all features live in `lib/features/<name>/`
- Do NOT use a GoRouter `redirect` for simple first-run routing — that logic belongs in `SplashCubit`; reserve `redirect` for auth-aware route protection (Phase 4+)

---

*These rules are binding for all EGY DEVELOPMENT development sessions.*
*Owner: EGY Development / Samah Elmenady*
*Last updated: 2026-11-17 (Rev 2 — corrections applied)*
