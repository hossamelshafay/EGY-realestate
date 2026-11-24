# Auth and Home scroll/performance refinement

Implemented in source on 2026-11-20. Runtime acceptance remains pending.

## Findings

- The session Stack painted the header above a separately scrolling form. The form's top offset was independently computed and capped at 55% of the keyboard-dependent viewport height. The header remained fixed while the form scrolled independently, and keyboard changes could shrink the allocation below its normal text/curve extent. The reported field overlap could not be reproduced on a device in this environment.
- Every result and shake controller tick notified the shared AuthShellMotion. That invalidated the shell, rebuilt its LayoutBuilder and recalculated four TextPainter layouts per frame. These are confirmed source-level rebuild costs, not measured device timings.
- Both supplied Lottie files are small (done: 6,221 bytes; Failed: 14,204 bytes). Their size alone does not explain severe lag. Lottie already [caches asset compositions internally](https://github.com/xvrh/lottie-flutter/blob/master/lib/src/providers/asset_provider.dart); repeated JSON parsing was not established as a cause.
- Forgot Password used the same asymmetric clipping route as Login. Home placed its full assistant banner in the separately scrolling content below the fixed header.

## Layout and navigation

SessionScrollLayout owns one CustomScrollView and one ScrollController. A non-pinned SliverToBoxAdapter reserves the header's complete curve extent, followed by the body sliver. The header and form therefore share one coordinate system. Scrolling translates the entire header out of view; its visible extent diminishes naturally. Scrolling toward the top restores it without scroll listeners, sticky behavior, height recalculation or independent collapse animations. Horizontal property paging remains independent.

Normal header height comes from localized text/asset geometry, not a percentage of the keyboard-reduced viewport. The form retains its existing internal spacing; extra padding does not mask the clipping defect.

For result feedback, a GlobalKey reparents the existing header subtree into a viewport overlay at its current screen position. The scroll layout retains a matching extent. The same navy surface expands to the full viewport, plays the result once and then either returns to its original scrolled position (failure), or morphs into Home (success). The successful flow resets scrolling under the opaque full-screen cover before releasing the existing auth redirect barrier. Completion returns that same header subtree to the Home sliver. The cached logo Image element remains mounted through reparenting.

The 750ms auth mode clock also returns a scrolled form toward its top during navigation. Login and Create Account retain their original mirrored cubic endpoints and form controllers. Forgot Password adds an interpolated symmetric endpoint matching the old BrandHeaderClipper inward corner geometry. Cubic subdivision preserves the original asymmetric curves exactly. No EN/AR selector is added to Reset.

Home embeds its assistant card under the greeting. Compact padding and robot dimensions are 25% smaller; text and arrow scale down proportionally. Header height includes measured banner text, robot extent and bottom-corner clearance. The approved convex corner endpoint, logo, greeting and menu placement are retained. Existing global theme configuration is unchanged (this checkout currently forces ThemeMode.light and contains no header theme-toggle control).

## Performance changes

- Only mode, cover and Home geometry clocks notify shell layout. Lottie drives its own bounded paint layer; shake drives local field builders. Phase/error notifications still reach inline feedback.
- A bounded text measurement cache handles locale, direction, width, text scale and text-style changes.
- AuthPage widgets are reused between geometry frames; form controllers and Cubit survive mode changes.
- Two composition Futures are prewarmed at shell creation and shared across attempts. Failed loads can retry; existing missing-asset fallback still releases navigation.
- RepaintBoundary separates the header, compact banner and 220x220 result playback. Existing controller instances, composition frame rate and result duration are retained.
- Home's static data/card subtree stays separate from its animated background and section wrappers.
- Router refreshes now depend on auth-guard state. Drawer and greeting rebuilds depend on visible user state, rather than every session emission.
- Existing reduced-motion phase completion remains in place. No animation package or backend dependency was added.

## Files

Created:

- lib/core/widgets/session_scroll_layout.dart
- lib/core/widgets/session_scroll_scope.dart
- lib/core/widgets/session_text_measurements.dart
- lib/features/authentication/presentation/widgets/auth_result_cache.dart
- test/features/authentication/session_scroll_test.dart
- test/features/authentication/auth_result_cache_test.dart
- docs/AUTH_SCROLL_PERFORMANCE.md

Modified:

- lib/core/widgets/session_page.dart
- lib/core/widgets/session_header_metrics.dart
- lib/core/widgets/shared_session_header.dart
- lib/app/router/app_router.dart
- lib/features/authentication/presentation/pages/auth_page.dart
- lib/features/authentication/presentation/widgets/asymmetric_auth_clipper.dart
- lib/features/authentication/presentation/widgets/auth_shell_motion.dart
- lib/features/authentication/presentation/widgets/auth_motion_scope.dart
- lib/features/authentication/presentation/widgets/auth_shell.dart
- lib/features/authentication/presentation/widgets/auth_feedback.dart
- lib/features/authentication/presentation/widgets/auth_result_animation.dart
- lib/features/home/presentation/pages/home_page.dart
- lib/features/home/presentation/widgets/home_assistant_banner.dart
- lib/features/home/presentation/widgets/drawer_scaffold.dart
- test/features/authentication/auth_page_test.dart
- test/features/authentication/auth_shell_motion_test.dart
- test/features/authentication/auth_retry_transition_test.dart
- test/features/home/home_page_test.dart

## Validation

- dart format lib/ test/: passed, 115 Dart files parsed/formatted. The formatter warned that the installed flutter_lints package could not be read.
- flutter analyze --no-pub: blocked before analysis.
- flutter test --no-pub: blocked before test execution.
- flutter build apk --debug --no-pub: blocked before compilation.
- flutter run --profile --no-pub and flutter devices: blocked before device discovery or deployment.

Flutter commands were invoked using the installed flutter_tools snapshot through its bundled Dart executable. Each fails because the environment cannot write C:/flutter/flutter_windows_3.32.0-stable/bin/cache/libimobiledevice.stamp. Package-cache reads are also restricted. No SDK permissions or Firebase settings were changed.

Added tests cover EN/AR field separation, header scrolling/restoration, keyboard-independent normal geometry, scrolled failure-cover return, Reset morph and saved email, compact banner containment, composition reuse/retry and result/shake tick isolation. Existing retry-success, auth/Home continuity and carousel tests were retained/adapted. These tests have NOT been run successfully in this environment.

Android 11 Profile Mode frame timings, rendered curve/layout matching, keyboard interaction, actual Firebase/Google completion and device animation smoothness remain unverified. Do not infer a measured frame-rate improvement from the source optimizations.

## Follow-up lifecycle review

Continued after the owner requested completion. Rechecking flutter analyze still fails on the same SDK cache stamp permissions.

- Feedback expansion now cancels any active drag or fling at its current offset, so the underlying form cannot drift away from the captured header origin during playback/return. The scrolled failure test now starts with a fling.
- Each result attempt has a revision guard. A delayed post-frame playback callback from an earlier failure cannot start or complete a newer successful attempt. Added a focused reduced-motion race test.
- Composition FutureBuilders are keyed by asset so switching from failure to success cannot retain the old composition snapshot or duration.

These follow-up changes remain subject to the same unexecuted Flutter tests and Android Profile Mode limitations above.
