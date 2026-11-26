import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'auth_cubit_test.dart' show FakeAuthRepository;

void main() {
  setUp(
    () => sl.registerFactory<AuthCubit>(() => AuthCubit(FakeAuthRepository())),
  );
  tearDown(() => sl.reset());
  testWidgets('registration validates mismatched passwords', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, state) => const AuthPage(mode: AuthPageMode.register),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizationConfig.delegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth_name')), 'Test User');
    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'test@example.com',
    );
    await tester.enterText(find.byKey(const Key('auth_password')), 'password1');
    await tester.enterText(
      find.byKey(const Key('auth_confirm_password')),
      'different',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('auth_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth_submit')));
    await tester.pump();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    router.dispose();
  });

  testWidgets('login and registration retain the same branded shell', (
    tester,
  ) async {
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
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizationConfig.delegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    final logo = tester.element(find.byKey(const Key('auth_logo')));
    await tester.enterText(
      find.byKey(const Key('auth_email')),
      'preserved@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('auth_password')),
      'preserved-password',
    );
    final header = find.byKey(const Key('brand_header_geometry'));
    final initialHeight = tester.getSize(header).height;
    router.go('/register');
    await tester.pump();
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 90));
      final headerRect = tester.getRect(header);
      final panelRect = tester.getRect(
        find.byKey(const Key('auth_form_panel')),
      );
      expect(
        headerRect.width,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
      final opacity = tester
          .widget<Opacity>(find.byKey(const Key('auth_form_motion')))
          .opacity;
      expect(
        panelRect.top,
        closeTo(headerRect.bottom - 16 * (1 - opacity), .01),
      );
      expect(tester.takeException(), isNull);
    }
    expect(tester.getSize(header).height, lessThan(initialHeight));
    await tester.pumpAndSettle();
    expect(
      identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
      isTrue,
    );
    expect(find.byKey(const Key('auth_name')), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('auth_email')))
          .controller!
          .text,
      'preserved@example.com',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('auth_password')))
          .controller!
          .text,
      'preserved-password',
    );
    router.go('/login');
    await tester.pumpAndSettle();
    expect(
      identical(logo, tester.element(find.byKey(const Key('auth_logo')))),
      isTrue,
    );
    expect(find.byKey(const Key('auth_name')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
