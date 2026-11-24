import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/widgets/primary_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PrimaryButton', () {
    testWidgets('renders gold variant label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Search',
            onPressed: () {},
            variant: PrimaryButtonVariant.gold,
          ),
        ),
      );
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('renders navy variant label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Register',
            onPressed: () {},
            variant: PrimaryButtonVariant.navy,
          ),
        ),
      );
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('renders blue variant label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Login',
            onPressed: () {},
            variant: PrimaryButtonVariant.blue,
          ),
        ),
      );
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(label: 'Login', isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Go', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when null (disabled)', (tester) async {
      await tester.pumpWidget(_wrap(const PrimaryButton(label: 'Disabled')));
      // ElevatedButton with null onPressed is disabled — tapping is a no-op.
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      // No exception thrown is sufficient.
      expect(tester.takeException(), isNull);
    });
  });
}
