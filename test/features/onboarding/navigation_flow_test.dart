import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/onboarding/presentation/widgets/onboarding_entrance.dart';
import 'package:egy/features/splash/presentation/pages/splash_page.dart';
import 'package:egy/features/splash/presentation/widgets/splash_sun_motion.dart';
import '../authentication/auth_cubit_test.dart' show FakeAuthRepository;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sl.registerFactory<AuthCubit>(() => AuthCubit(FakeAuthRepository()));
  });
  tearDown(() => sl.reset());

  testWidgets(
    'real routes overlap splash, persist locale and reach both auth destinations',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = await SharedPreferences.getInstance();
      appRouter.goNamed(RouteNames.splash);
      await tester.pumpWidget(App(prefs: prefs));
      await tester.pump();
      final logoRect = tester.getRect(find.byKey(const Key('splash_logo')));
      await tester.pump(const Duration(milliseconds: 2900));
      final reveal = tester.widget<ClipRect>(
        find.byKey(const Key('splash_logo_reveal')),
      );
      expect(
        (reveal.clipper! as SunLogoClipper).progress,
        inExclusiveRange(0, 1),
      );
      expect(tester.getRect(find.byKey(const Key('splash_logo'))), logoRect);
      await tester.pump(const Duration(milliseconds: 1090));
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.byType(OnboardingEntrance), findsNothing);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump();
      // Both surfaces are mounted before the original five-second endpoint.
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.byType(OnboardingEntrance), findsOneWidget);
      double entrance(int stage) => tester
          .widget<Opacity>(
            find.byKey(ValueKey('onboarding_entrance_$stage')).first,
          )
          .opacity;
      expect(entrance(0), 0);
      expect(entrance(1), 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(entrance(0), greaterThan(0));
      expect(entrance(1), 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(entrance(1), greaterThan(0));
      expect(entrance(2), 0);
      final enteringOnboarding = tester.element(
        find.byKey(const Key('onboarding_pages')),
      );
      expect(find.byType(SplashPage), findsOneWidget);
      await tester.pumpAndSettle();
      expect(
        identical(
          enteringOnboarding,
          tester.element(find.byKey(const Key('onboarding_pages'))),
        ),
        isTrue,
      );
      expect(find.byType(SplashPage), findsNothing);
      await tester.tap(find.byKey(const Key('onboarding_language_ar')));
      await tester.pumpAndSettle();
      expect(prefs.getString('locale'), 'ar');
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('onboarding_pages'))),
        ),
        TextDirection.rtl,
      );
      await tester.tap(find.byKey(const Key('skip')));
      await tester.pumpAndSettle();
      for (final destination in ['log_in', 'create_account']) {
        final action = destination == 'log_in'
            ? tester
                  .widget<FilledButton>(find.byKey(Key(destination)))
                  .onPressed!
            : tester
                  .widget<OutlinedButton>(find.byKey(Key(destination)))
                  .onPressed!;
        action();
        action(); // The in-flight guard must reject the second invocation.
        await tester.pump();
        await tester.pump(); // Establish the handoff ticker's first timestamp.
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byKey(const Key('onboarding_pages')), findsOneWidget);
        expect(find.byKey(const Key('auth_logo')), findsOneWidget);
        double authOpacity(int stage) => tester
            .widget<Opacity>(find.byKey(ValueKey('auth_entrance_$stage')).first)
            .opacity;
        expect(authOpacity(0), greaterThan(0));
        expect(authOpacity(4), 0);
        final outgoing = find
            .descendant(
              of: find.byKey(const ValueKey('onboarding_illustration_2')),
              matching: find.byType(Opacity),
            )
            .first;
        expect(tester.widget<Opacity>(outgoing).opacity, lessThan(1));
        await tester.pump(const Duration(milliseconds: 350));
        expect(authOpacity(4), greaterThan(0));
        expect(authOpacity(5), 0);
        expect(authOpacity(7), 0);
        expect(authOpacity(8), 0);
        expect(authOpacity(9), 0);
        await tester.pumpAndSettle();
        expect(
          appRouter.state.uri.path,
          destination == 'log_in' ? RoutePaths.login : RoutePaths.register,
        );
        expect(
          Localizations.localeOf(
            tester.element(find.byKey(const Key('auth_email'))),
          ).languageCode,
          'ar',
        );
        expect(find.byType(AuthPage), findsOneWidget);
        appRouter.pop();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(destination)));
        await tester.pumpAndSettle();
        expect(find.byType(AuthPage), findsOneWidget);
        final logoElement = tester.element(find.byKey(const Key('auth_logo')));
        appRouter.goNamed(
          destination == 'log_in' ? RouteNames.register : RouteNames.login,
        );
        await tester.pumpAndSettle();
        expect(
          identical(
            logoElement,
            tester.element(find.byKey(const Key('auth_logo'))),
          ),
          isTrue,
        );
        // Return to the final onboarding slide for the other destination.
        appRouter.goNamed(RouteNames.onboarding);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('skip')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('onboarding_pages')), findsOneWidget);
      }
      appRouter.goNamed(RouteNames.forgotPassword);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth_language_en')), findsNothing);
      expect(find.byKey(const Key('auth_email')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
