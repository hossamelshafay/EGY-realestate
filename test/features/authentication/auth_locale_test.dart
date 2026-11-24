import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_header.dart';
import 'auth_cubit_test.dart' show FakeAuthRepository;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sl.registerFactory<AuthCubit>(() => AuthCubit(FakeAuthRepository()));
  });
  tearDown(() => sl.reset());
  test(
    'concave geometry has a straight centre and inverted corner returns',
    () {
      final path = const BrandHeaderClipper(32).getClip(const Size(360, 280));
      expect(path.contains(const Offset(180, 240)), isTrue);
      expect(path.contains(const Offset(180, 260)), isFalse);
      expect(path.contains(const Offset(359, 260)), isTrue);
      expect(path.contains(const Offset(1, 260)), isTrue);
    },
  );
  testWidgets('real App switches EN AR EN on both forms and persists locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        for (final mode in [AuthPageMode.login, AuthPageMode.register])
          GoRoute(
            path: mode == AuthPageMode.login ? '/login' : '/register',
            pageBuilder: (_, state) => NoTransitionPage<void>(
              key: const ValueKey('auth_shell'),
              child: AuthPage(mode: mode),
            ),
          ),
      ],
    );
    await tester.pumpWidget(App(prefs: prefs, router: router));
    await tester.pumpAndSettle();
    final logo = tester.element(find.byKey(const Key('auth_logo')));
    for (final route in ['/login', '/register']) {
      router.go(route);
      await tester.pumpAndSettle();
      for (final code in ['en', 'ar', 'en']) {
        final selector = find.byKey(Key('auth_language_$code'));
        await tester.ensureVisible(selector);
        await tester.tap(selector);
        await tester.pumpAndSettle();
        final field = find.byKey(const Key('auth_email'));
        final context = tester.element(field);
        expect(Localizations.localeOf(context).languageCode, code);
        expect(
          Directionality.of(context),
          code == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(MaterialLocalizations.of(context), isNotNull);
        final email = tester.widget<EditableText>(
          find.descendant(of: field, matching: find.byType(EditableText)),
        );
        expect(email.textDirection, TextDirection.ltr);
        expect(email.textAlign, TextAlign.start);
        final mail = find.descendant(
          of: field,
          matching: find.byIcon(Icons.mail_outline),
        );
        final mailX = tester.getCenter(mail).dx;
        final fieldX = tester.getCenter(field).dx;
        expect(code == 'ar' ? mailX > fieldX : mailX < fieldX, isTrue);
        for (final key in [
          'auth_password',
          if (route == '/register') 'auth_name',
          if (route == '/register') 'auth_confirm_password',
        ]) {
          final input = find.byKey(Key(key));
          expect(input, findsOneWidget);
          expect(MaterialLocalizations.of(tester.element(input)), isNotNull);
        }
        await tester.ensureVisible(field);
        await tester.enterText(field, 'user@example.com');
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(prefs.getString('locale') ?? 'en', code);
        expect(
          identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
          isTrue,
        );
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
