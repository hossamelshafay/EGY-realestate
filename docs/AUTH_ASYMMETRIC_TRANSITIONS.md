# Asymmetric Auth geometry and result transitions

## Reference and scope

The inspected reference is docs/design_references/slate_login_curve.png. Only its curved lower boundary is used: the login path starts low on the left, dips into a broad valley, then climbs steeply at the right. Registration reverses the same normalized cubic controls horizontally. EGY navy and the original asset remain unchanged.

Hash checks preserve the Home feature, original BrandHeaderClipper implementation used by Home, Splash, Onboarding, and Firebase datasource/repository. No account lockout, backend or Firebase configuration was introduced.

## Header and form switching

AsymmetricAuthClipper constructs two cubic B?zier segments from interpolated control points. A single 750 ms mode clock contracts header height, flattens the boundary into a compact midpoint, exchanges the invisible form intent, then unfolds the mirrored valley. Logo placement, title/subtitle opacity/position and form opacity/slide read the same clock. All input controllers and the auth Cubit remain mounted, including passwords and confirm-password values. Forgot Password retains its existing field/language behavior.

A stable shared SessionPage/SharedSessionHeader shell owns the surface. Stack-level layer keys preserve the actual ClipPath, ColoredBox and Image elements when Home is inserted and the form is eventually removed. Direct AuthPage entry points delegate to that same shell instead of falling back to a second header design.

## First failure, retries and success

AuthCubit counts backend submission failures only to choose feedback. Local validation does not consume the first-failure presentation, and Google cancellation is not counted. The first failure expands the existing navy surface over 520 ms, plays the bundled assets/lottie/Failed.json once, then contracts and exposes a localized inline error. Subsequent failures shake implicated fields over 420 ms and briefly tint their border red; network errors do not falsely mark credential fields. Attempts are never denied by a client counter.

Any successful email login, registration or Google operation emits AuthSuccess, regardless of prior failures. The loading state ends, then the shell expands over 520 ms. Only once the full navy viewport is established is assets/lottie/done.json mounted and played. Playback is repeat:false and uses its own composition duration through onLoaded and an AnimationController completion event, not a fixed wait. The provided assets are approximately 2.625 seconds (done) and 2.002 seconds (Failed). The actual filename has a capital F and is referenced exactly for Android assets.

SessionCubit.awaitingFeedback keeps the existing authentication route protected from early Firebase auth-state redirects while playback runs. It is independent of the loading state. Only player completion releases navigation. Repeated Firebase events retain this gate. A stable auth_shell page key preserves the shell during the Home redirect.

For success-to-Home, the very same full-height navy surface shrinks over 900 ms as Home content follows directly below its moving lower edge. Its corners approach the approved Home path; at the endpoint the clipper delegates to the original unchanged BrandHeaderClipper with 32 px convex returns. Home header height, SafeArea, logo position/size, greeting and menu endpoint are preserved. Neither the route nor the navy surface is independently cross-faded. The source logo Image remains mounted even while deliberately hidden for the result presentation.

Reduced-motion users settle geometry immediately and complete result playback without a looping wait. In-flight reduction and disposal cancel presentation futures safely. Missing/corrupt animation assets have a completion fallback so a confirmed user cannot be stranded. If the session disappears during feedback, the shell returns to the auth form rather than bypassing the guard.

## Dependencies

The project did not have a Lottie player. pubspec.yaml now declares lottie ^3.8.2 and bundles assets/lottie/. This is the pure-Dart player documented at https://pub.dev/packages/lottie; composition frame rate is retained for Android efficiency. Existing JSON assets are not edited. Dependency resolution must succeed before compilation; pubspec.lock was not fabricated or manually rewritten.

## Validation

- Inspected the SLATE screenshot and parsed both actual Lottie JSON files successfully.
- Dart formatting completes for the modified/new source and tests. Source checks enforce handwritten files below 400 lines and preserved-file hashes.
- Added tests for mirror geometry, the unchanged Home clipper endpoint, the 750 ms fold midpoint, first/subsequent failure phases, later full success, result-completion gating and in-flight reduced motion.
- Expanded integration tests to assert full-screen coverage before playback, the mounted correct asset/controller/repeat flag, no Home redirect before completion, identical navy/clip and logo elements through navigation, all authentication providers, preserved typed fields, repeated auth events, and retries without lockout. Player completion is explicitly signalled in navigation tests; those tests do not claim visual playback QA.
- Attempted flutter pub get, flutter analyze and flutter test using the installed SDK tool. All stopped before execution because bin/cache/libimobiledevice.stamp is outside the writable workspace. The formatter also reports the configured flutter_lints Pub-cache file inaccessible.
- Lottie dependency resolution and a refreshed lockfile remain blocked, so compilation, passing tests and actual Android playback are unverified. No passing analysis/test run or exact on-device pixel match is claimed.

## Added files

- lib/features/authentication/presentation/pages/auth_page_mode.dart
- lib/features/authentication/presentation/widgets/asymmetric_auth_clipper.dart
- lib/features/authentication/presentation/widgets/auth_shell_motion.dart
- lib/features/authentication/presentation/widgets/auth_motion_scope.dart
- lib/features/authentication/presentation/widgets/auth_result_animation.dart
- lib/features/authentication/presentation/widgets/auth_feedback.dart
- lib/features/authentication/presentation/widgets/auth_password_field.dart
- lib/core/widgets/session_header_metrics.dart
- test/features/authentication/auth_shell_motion_test.dart
- test/features/authentication/auth_retry_transition_test.dart

## Modified files

- lib/core/widgets/session_page.dart
- lib/core/widgets/shared_session_header.dart
- lib/features/authentication/presentation/pages/auth_page.dart
- lib/features/authentication/presentation/widgets/auth_shell.dart
- lib/features/authentication/presentation/cubit/auth_cubit.dart
- lib/features/authentication/presentation/cubit/session_cubit.dart
- lib/app/router/session_redirect.dart
- pubspec.yaml
- test/features/authentication/auth_page_test.dart
- test/features/authentication/session_cubit_test.dart
- test/features/home/auth_home_transition_test.dart
- test/support/session_repository.dart
