import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:egy/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/authentication/auth_cubit_test.dart'
    show FakeAuthRepository;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => sl.registerFactory(() => AuthCubit(FakeAuthRepository())));
  tearDown(() => sl.reset());
  for (final mode in AuthPageMode.values) {
    testWidgets('restored Dark reaches $mode and its form fields', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        ThemeCubit.preferenceKey: 'dark',
      });
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => AuthPage(mode: mode),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        App(prefs: await SharedPreferences.getInstance(), router: router),
      );
      await tester.pumpAndSettle();
      final field = find.byType(EditableText).first;
      expect(Theme.of(tester.element(field)).brightness, Brightness.dark);
      expect(
        tester.widget<EditableText>(field).style.color,
        AppColors.darkText,
      );
      final controller = tester.element(field).read<ThemeCubit>();
      expect(controller.state.mode, ThemeMode.dark);

      expect(controller.state.mode, ThemeMode.dark);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'Onboarding stays Light without changing the saved Dark preference',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        ThemeCubit.preferenceKey: 'dark',
      });
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const OnboardingPage())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        App(prefs: await SharedPreferences.getInstance(), router: router),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(const Key('onboarding_pages')));
      expect(Theme.of(context).brightness, Brightness.light);
      expect(context.read<ThemeCubit>().state.mode, ThemeMode.dark);
      expect(find.byKey(const Key('theme_toggle')), findsNothing);
      expect(find.byKey(const Key('theme_menu')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('restored Dark reaches Flutter Splash before first routing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({ThemeCubit.preferenceKey: 'dark'});
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SplashPageWrapper()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      App(prefs: await SharedPreferences.getInstance(), router: router),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final context = tester.element(find.byType(SplashPage));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == AppColors.darkCanvas,
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
