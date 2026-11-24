import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/app_dimensions.dart';
import 'package:egy/app/theme/app_theme.dart';

/// Helper: wraps [child] in a full [MaterialApp] with [AppTheme.light].
///
/// Calling [AppTheme.light] triggers Google Fonts loading, which is async.
/// Widget tests pump frames so the font-load exception is captured and
/// discarded before assertions run.
Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() {
    // Suppress network fetching — Google Fonts falls back gracefully to the
    // system font when assets are absent.  Exceptions are handled below.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppColors tokens', () {
    test('primaryNavy matches approved hex', () {
      expect(AppColors.primaryNavy, const Color(0xFF031A2D));
    });

    test('secondaryNavy matches approved hex', () {
      expect(AppColors.secondaryNavy, const Color(0xFF06233E));
    });

    test('primaryGold matches approved hex', () {
      expect(AppColors.primaryGold, const Color(0xFFE5A11A));
    });

    test('infoBlue matches approved hex — Login button colour', () {
      expect(AppColors.infoBlue, const Color(0xFF2563EB));
    });

    test('destructiveRed matches approved hex', () {
      expect(AppColors.destructiveRed, const Color(0xFFDC2626));
    });

    test('offWhite matches approved hex', () {
      expect(AppColors.offWhite, const Color(0xFFF7F8FA));
    });

    test('white is pure white', () {
      expect(AppColors.white, const Color(0xFFFFFFFF));
    });

    test('textOnDark is white', () {
      expect(AppColors.textOnDark, const Color(0xFFFFFFFF));
    });

    test('goldGradient starts with primaryGold', () {
      expect(AppColors.goldGradient.colors.first, AppColors.primaryGold);
    });

    test('navyGradient starts with primaryNavy', () {
      expect(AppColors.navyGradient.colors.first, AppColors.primaryNavy);
    });
  });

  group('AppDimensions tokens', () {
    test('buttonHeight is 52', () => expect(AppDimensions.buttonHeight, 52));
    test('radiusXl is 24', () => expect(AppDimensions.radiusXl, 24));
    test('base spacing is 16', () => expect(AppDimensions.base, 16));
  });

  group('AppTheme — ColorScheme (via widget)', () {
    testWidgets('light theme ColorScheme.primary is primaryNavy', (
      tester,
    ) async {
      late ColorScheme scheme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) {
              scheme = Theme.of(ctx).colorScheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // Pump once more to clear any pending font-load microtasks.
      await tester.pump();
      expect(scheme.primary, AppColors.primaryNavy);
    });

    testWidgets('light theme ColorScheme.secondary is primaryGold', (
      tester,
    ) async {
      late ColorScheme scheme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) {
              scheme = Theme.of(ctx).colorScheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      expect(scheme.secondary, AppColors.primaryGold);
    });

    testWidgets('light theme ColorScheme.error is destructiveRed', (
      tester,
    ) async {
      late ColorScheme scheme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) {
              scheme = Theme.of(ctx).colorScheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      expect(scheme.error, AppColors.destructiveRed);
    });

    testWidgets('light theme scaffoldBackgroundColor is offWhite', (
      tester,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) {
              theme = Theme.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      expect(theme.scaffoldBackgroundColor, AppColors.offWhite);
    });

    testWidgets('dark theme stub brightness is dark', (tester) async {
      expect(AppTheme.dark.brightness, Brightness.dark);
    });
  });
}
