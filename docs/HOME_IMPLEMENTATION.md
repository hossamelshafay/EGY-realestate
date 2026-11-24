# Phase 5: Home and the Auth-to-Home morph

Home content has since been revised to the reference. See [Home content redesign](HOME_CONTENT_REDESIGN.md) for the current UI, asset provenance and validation. The shared header and morph remain unchanged.

## Scope and UI

Home follows 05_home.jpg and 06_navigation_drawer.jpg: navy greeting header, compact original logo, discovery controls, featured property carousel, AI entry points and a drawer. Approved navigation remains drawer-only. No bottom bar or dark-mode toggle was introduced.

Home lives under features/home with presentation/pages and presentation/widgets. HomeCubit owns local query, location, property type and temporary favourite selections. No property repository is invented for local samples. Full Recommendations, Prediction, Assistant, Favorites, Settings and Profile destinations remain localized future-feature placeholders.

## Persistent transition

Auth intents and Home share the auth_shell page key inside one ShellRoute and DrawerScaffold. SessionPage State and its Image element survive the successful-auth redirect. The persistent shell holds the outgoing AuthPage in a Stack until its 900 ms morph finishes, while mounting Home immediately with zero initial section opacity. The original asset remains in one stable header child throughout; it is not a duplicate logo or a Hero snapshot.

SharedSessionHeader clips the actual navy surface with BrandHeaderClipper.morph. The two corner curves keep identical path topology. Their edge and centre coordinates interpolate from inward concave returns, through a flat edge, to outward convex rounding. The same shell clock interpolates header height, logo size and vertical position. Separate form stages fade/slide out as Home discovery, section headings, preview cards and AI tools enter successively. Auth title and locale changes retain the existing short switch animation. Background colour is independent of content opacity.

Home discards completed Onboarding transition extras instead of reusing them for the new morph. A specifically tagged, still-active Splash handoff supports restored-session entry. Splash's five-second clock, skyline painter and sun reveal are otherwise unchanged. Its Cubit can now choose Home for an existing authenticated user even if the onboarding preference is absent.

Reduced motion settles the shape and clock immediately. Keyboard dismissal precedes the success morph; a responsive maximum header height leaves scrolling space for forms on small keyboard-constrained viewports. Handwritten files remain under 400 lines.

## Authentication and routing

SessionCubit observes the existing AuthRepository. Widgets do not import Firebase APIs or make backend calls. AuthCubit holds SessionCubit.authenticating around existing email, registration and Google operations. An early Firebase event updates the session, but the guard retains the current Auth route until the operation and registration display-name update finish. The guard then sends the session to Home once. Further auth events on Home do not restart the morph. Signed-out sessions still redirect protected routes to Login. Drawer logout uses the same repository's Firebase/Google signOut and exposes failures.

## Data sources

- Real session, display name and logout: existing Firebase/Google AuthRepository.
- Documented listing API: /api/recommendations/featured/list. Endpoint constants exist, but Home has no connected Flutter listing datasource/repository or configured production backend.
- Preview only: HomePreviewCatalog has three sample records with illustrative prices/details and a generated architectural preview photograph. Home labels these as non-live listings and temporary favourites. Search and filters affect these samples only. They are not presented as AI recommendations.
- No Python backend, Firebase configuration, dependency manifest, HTTP integration, production collection or new image download was changed.

## Validation

- dart format lib/ test/: completed, then checked again with zero changes. The tool warns that the configured flutter_lints Pub-cache file is inaccessible.
- ARB key parity and checked-in Home localization member consistency: passed a local source check. ARB sources and existing bindings were synchronized; Flutter localization generation remains unverified under the SDK restriction.
- flutter analyze, flutter test and flutter build apk --debug: attempted with no-pub through the installed Flutter tool. All stopped before analysis, tests or compilation because the SDK could not write bin/cache/libimobiledevice.stamp outside the writable workspace.
- Added tests cover filtering, immutable favourites, early Firebase events, profile-name completion, restored Splash routing, logout failure/success, narrow EN/AR layouts, email/register/Google morphs, completed Onboarding extras, intermediate corner geometry, Home opacity, logo Element identity, repeated auth events and reduced motion.
- No passing Flutter analysis/test result, fresh APK, emulator playback, physical Android 11 playback or screenshot review of the running Flutter screen is claimed. Phase completion remains pending these checks.

## Created files

- lib/features/home/data/home_preview_catalog.dart
- lib/features/home/domain/entities/preview_property.dart
- lib/features/home/presentation/cubit/home_cubit.dart
- lib/features/home/presentation/pages/home_page.dart
- lib/features/home/presentation/widgets/drawer_scaffold.dart
- lib/features/home/presentation/widgets/home_ai_tools.dart
- lib/features/home/presentation/widgets/home_discovery.dart
- lib/features/home/presentation/widgets/home_labels.dart
- lib/features/home/presentation/widgets/home_stage.dart
- lib/features/home/presentation/widgets/property_preview_card.dart
- lib/features/authentication/presentation/cubit/session_cubit.dart
- lib/core/widgets/session_page.dart
- lib/core/widgets/session_morph_scope.dart
- lib/core/widgets/shared_session_header.dart
- lib/core/widgets/session_header_text.dart
- lib/app/router/session_redirect.dart
- test/features/home/home_cubit_test.dart
- test/features/home/home_page_test.dart
- test/features/home/auth_home_transition_test.dart
- test/features/authentication/session_cubit_test.dart
- test/support/session_repository.dart
- docs/HOME_IMPLEMENTATION.md

## Modified files

- lib/app/router/app_router.dart
- lib/app/router/screen_handoff.dart
- lib/app/di/injection.dart
- lib/features/authentication/presentation/cubit/auth_cubit.dart
- lib/features/authentication/presentation/pages/auth_page.dart
- lib/features/authentication/presentation/widgets/auth_shell.dart
- lib/features/authentication/presentation/widgets/auth_entrance.dart
- lib/features/authentication/presentation/widgets/auth_header.dart
- lib/features/splash/presentation/cubit/splash_cubit.dart
- lib/features/splash/presentation/pages/splash_page.dart
- lib/app/localization/arb/app_en.arb
- lib/app/localization/arb/app_ar.arb
- lib/app/localization/generated/app_localizations.dart
- lib/app/localization/generated/app_localizations_en.dart
- lib/app/localization/generated/app_localizations_ar.dart
- docs/MASTER_PLAN.md
- docs/DEVELOPMENT_ROADMAP.md
