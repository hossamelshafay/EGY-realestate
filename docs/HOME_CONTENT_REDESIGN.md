# Home content redesign

## Scope preserved

The redesign changes only Home content, its preview image data and localization. SHA-256 checks confirm all 37 captured header, Auth-to-Home morph, authentication, router, global theme, Splash and Onboarding Dart files are byte-for-byte unchanged. No backend, Firebase configuration, dependency, navigation shell or header geometry was edited.

The repository's docs/design_references/05_home.jpg is the available Home reference used. The existing top navy header remains in its original owner, entirely outside the redesigned Home content.

## Updated content

- Assistant banner directly below the header: navy fill, fine gold outline, gentle shadow, native friendly robot artwork at the directional end, personalized-assistance copy and circular gold action.
- Rounded, softly filled search field with the requested property/area/developer hint, plus a gold filter action. Existing local type/location filtering remains available through a bottom sheet.
- Four equal category cards: Residential for Sale/Rent and Commercial for Sale/Rent. The first has gold emphasis; others use theme surfaces. Entry actions explain that future browsing is not implemented. Large accessibility text uses horizontal scrolling rather than clipped labels.
- Featured heading with opposite View All action, clear preview disclosure and an actual PageView carousel. Photo cards have rounded clipping, a sale badge, favorite action, localized title/location/price/specifications and a navy bottom gradient.
- Indicator width, colour and selected semantics follow the PageController's fractional page. Indicator taps navigate the same controller. Reduced motion uses instant selection; filters reset the carousel only when result IDs change.
- Two compact AI tool cards for Price Predictor and Recommendations, with gold icons, supporting copy and circular actions. Banner, categories, View All and tools use localized future-feature sheets; no full AI or browsing feature was built.

## Assets and data

All properties, prices and favorites still come from the isolated HomePreviewCatalog. They are explicitly labeled as sample/non-live listings. No backend connectivity is invented.

The imagegen skill generated assets/img/home-property-preview.png, copied into the existing bundled asset directory and visually inspected. It is a fictional architectural photograph for preview use, not a photograph of a real advertised listing. The prompt requested a modern New Cairo apartment facade, palm landscaping, natural afternoon light, and no text, logos or UI. The same illustration is reused for sample cards. Runtime decode width is capped at 960 pixels. The robot uses inexpensive native Flutter shapes, not a heavy animation package or blur filter.

## Theme and localization

HomePalette uses the active Theme brightness and semantic colour tokens. New content supports both Light and Dark contexts, and Row/PositionedDirectional placements mirror the robot, category order, badge/favorite placement and actions in Arabic. All new copy is in EN/AR ARBs with synchronized checked-in localization bindings.

Important limitation: the current repository still forces ThemeMode.light in App and has no implemented header theme toggle. That pre-existing global behavior was preserved exactly, as required by the header-only exclusion. This change makes Home content theme-aware; it does not add or activate a global toggle.

## Validation

- Dart formatting completed for changed Dart files; a final formatting check is recorded at delivery.
- Local checks confirm protected-file hashes, EN/AR key parity, generated Home localization members, bundled image existence, and handwritten line limits.
- Home widget tests now cover a 320 dp viewport in both locales and both theme contexts, robot mirroring, four categories, both tool cards, canvas colours, favorites, actual carousel swiping/controller page, empty search results, scaled Arabic, reduced-motion indicator taps and future-feature actions.
- flutter analyze, flutter test and flutter build apk --debug were attempted through the installed Flutter tool with no-pub. Each stopped before executing because it could not write bin/cache/libimobiledevice.stamp outside the workspace. The formatter also warns that the configured flutter_lints Pub-cache file is inaccessible.
- No passing Flutter analysis/test run, fresh debug APK or running Android visual verification is claimed. The reference and generated photo were visually inspected; the running Flutter layout remains unverified.

## Modified files

- lib/features/home/presentation/pages/home_page.dart
- lib/features/home/presentation/widgets/home_discovery.dart
- lib/features/home/presentation/widgets/home_ai_tools.dart
- lib/features/home/presentation/widgets/property_preview_card.dart
- lib/features/home/domain/entities/preview_property.dart
- lib/features/home/data/home_preview_catalog.dart
- lib/app/localization/arb/app_en.arb
- lib/app/localization/arb/app_ar.arb
- lib/app/localization/generated/app_localizations.dart
- lib/app/localization/generated/app_localizations_en.dart
- lib/app/localization/generated/app_localizations_ar.dart
- test/features/home/home_page_test.dart
- docs/HOME_IMPLEMENTATION.md

## Added files

- lib/features/home/presentation/widgets/home_assistant_banner.dart
- lib/features/home/presentation/widgets/home_categories.dart
- lib/features/home/presentation/widgets/home_featured_carousel.dart
- lib/features/home/presentation/widgets/home_carousel_indicators.dart
- lib/features/home/presentation/widgets/home_circle_action.dart
- lib/features/home/presentation/widgets/home_actions.dart
- lib/features/home/presentation/widgets/home_filters_sheet.dart
- lib/features/home/presentation/widgets/home_palette.dart
- assets/img/home-property-preview.png
- docs/HOME_CONTENT_REDESIGN.md
