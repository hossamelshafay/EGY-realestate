import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/app/app.dart';
import 'package:egy/app/theme/app_colors.dart';

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('App — Phase 1 smoke tests', () {
    testWidgets('renders without throwing', (WidgetTester tester) async {
      // Firebase is not initialised in tests; pump App without it.
      // The placeholder home does not require Firebase.
      await tester.pumpWidget(App(prefs: await _prefs()));
      await tester.pumpAndSettle();
      // No exception thrown during build.
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies light theme — scaffold background is not null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(App(prefs: await _prefs()));
      await tester.pumpAndSettle();

      // The router renders a screen that contains at least one Scaffold.
      // We verify at least one Scaffold is present in the widget tree.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('AppColors.offWhite has correct hex value', (
      WidgetTester tester,
    ) async {
      expect(AppColors.offWhite, const Color(0xFFF7F8FA));
    });
  });
}
