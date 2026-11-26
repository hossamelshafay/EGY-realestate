# Appearance and curved surfaces

Use the appearance icon on Home/authentication or Onboarding, or the three
appearance buttons in the reveal menu. Light, Dark, and System are device-local
preferences. `ThemeCubit` reads `appearance_mode` from SharedPreferences before
building MaterialApp. Logout does not own or clear this preference.

The existing router, authentication Cubits, chat persistence and repositories stay
mounted when appearance changes. MaterialApp's theme tween is disabled; the custom
reveal is the single theme animation clock (760 ms, easeInOutCubic). Navigation
remains 500 ms forward / 420 ms reverse.

`ThemeReveal` keeps one live navigator. It captures the outgoing render surface into
a temporary in-memory GPU image, applies the new theme, and clips the old pixels.
Light-to-Dark removes an expanding circular hole from the outgoing Light layer.
Dark-to-Light clips the outgoing Dark layer to a shrinking disk. The origin is the
selected control's measured global center, converted into reveal coordinates.
The radius is the maximum distance from that origin to the four screen corners.
Images are never saved, sent, logged or exposed to accessibility and are disposed
after use. Rapid choices keep the last queued mode. Route changes, window metrics,
platform brightness changes and reduced motion cancel the visual overlay without
resetting app state. System appearance changes apply without a synthetic origin.

`BrandHeaderClipper` now lives in core and is re-exported from the old auth import
for compatibility. Its path mathematics are unchanged. `BrandCurveSurface` applies
the inward variant with a 32px proportion in AuthenticatedScaffold. This covers
Recommendations/filter/results, Favorites, Chat, Prediction, catalog and existing
Profile/Settings placeholders. Search retains its expanding Home overlay rather
than gaining an unrelated header. Home retains its existing convex brand endpoint;
Login/Signup/Reset keep their exact asymmetric/mirrored paths and dimensions.

`CurveDivider` extracts only the existing bottom boundary and strokes it white
(1 logical pixel, 80% opacity) in Dark Mode. It does not outline rectangular sides
or change clipping. Home, asymmetric authentication, internal headers and Property
Details use it. Splash and Onboarding have illustrations, not separate curved
upper panels; they receive theme-aware backgrounds and text without invented
headers or artificial strokes across artwork.

`PropertyImageClipper` creates a quadratic convex bottom edge with depth equal to
8.5% of image height. Hero flights interpolate both corner radius and curve amount
between card and details geometry. Floating actions and information entrances are
independent of that clipping path.

Dark styling covers Flutter Splash/Onboarding, every authentication form, Home,
search, property details/catalog, Favorites, recommendations, chat, prediction,
placeholders, menus, dialogs, fields and shared controls. Android night resources
also match the charcoal canvas. The OS-created launch window follows Android's
resource/night setting before Flutter can read an explicit app preference; the
Flutter Splash screen itself always follows the saved app selection.

## Files in this change

- App/theme: `lib/app/app.dart`, `lib/app/theme/app_colors.dart`, `app_theme.dart`,
  `app_palette.dart`, `theme_cubit.dart`, `theme_reveal.dart`, `theme_selector.dart`.
- Localization: both ARB files and their generated localization classes.
- Routing: `lib/app/router/app_router.dart` (placeholder text colors only).
- Shared widgets: `authenticated_scaffold.dart`, `shared_session_header.dart`,
  `session_page.dart`, `brand_header_clipper.dart`, `brand_curve_surface.dart`,
  `curve_divider.dart`, `app_text_field.dart`, `loading_view.dart`,
  `rounded_content_panel.dart`, `primary_button.dart`, `secondary_button.dart`,
  `locale_selector.dart`, under `lib/core/widgets/`.
- Authentication: `auth_page.dart`, `auth_header.dart`, `auth_shell.dart`,
  `auth_style.dart`, `auth_password_field.dart`, `auth_action_button.dart`.
- Onboarding: `onboarding_page.dart`, `onboarding_slide.dart`.
- Splash: `splash_page.dart`, `cairo_skyline_painter.dart` (colors only).
- Home: `drawer_scaffold.dart`, `reveal_menu.dart` (appearance controls only).
- Other feature colors: `favorite_button.dart`, `chat_page.dart`,
  `prediction_result.dart`.
- Properties: `property_details_page.dart`, `property_hero.dart`,
  `property_image_clipper.dart`.
- Android: `res/values-night/colors.xml`, `res/values-night/styles.xml`.
- Tests: `test/app/theme/theme_controller_test.dart`, `theme_reveal_test.dart`,
  `theme_screen_coverage_test.dart`.
- Documentation: `docs/MASTER_PLAN.md` and this file.

Validation is run with `flutter analyze --no-pub` and
`flutter test --no-pub --concurrency=1 --timeout=45s`. Theme tests cover restoration,
mock logout/login, actual circle topology, convex geometry, rapid choices, System
brightness, reduced motion, retained route/input identity, and all auth/intro pages.
No backend, Firebase configuration, ChatCubit, chat storage, account functionality,
avatars, Web or iOS implementation is part of this change.
