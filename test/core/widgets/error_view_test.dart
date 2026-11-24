import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/widgets/error_view.dart';
import 'package:egy/core/widgets/primary_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('ErrorView', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(
        _wrap(const ErrorView(message: 'Connection failed')),
      );
      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorView(message: 'Error')));
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Failed to load',
            onRetry: () {},
            retryLabel: 'Try Again',
          ),
        ),
      );
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ErrorView(message: 'Fatal error')));
      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Failed',
            onRetry: () => retried = true,
            retryLabel: 'Retry',
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
