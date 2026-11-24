import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/widgets/app_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('AppTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            controller: TextEditingController(),
            label: 'Email',
            hint: 'Enter email',
          ),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text inside the field', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            controller: TextEditingController(),
            label: 'Email',
            hint: 'Enter email',
          ),
        ),
      );
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('shows errorText when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            controller: TextEditingController(),
            label: 'Email',
            errorText: 'Invalid email',
          ),
        ),
      );
      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      final controller = TextEditingController(text: 'secret');
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ),
      );
      final field = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(field.obscureText, isTrue);
    });
  });
}
