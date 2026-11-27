import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/authentication/web/pages/web_auth_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/session_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildHarness({
    required WebAuthMode mode,
    required AuthCubit authCubit,
    Locale locale = const Locale('en'),
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefs)),
        BlocProvider(create: (_) => LocaleCubit(prefs)..setLocale(locale)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizationConfig.delegates,
        supportedLocales: LocaleCubit.supportedLocales,
        home: WebAuthPage(mode: mode, cubit: authCubit),
      ),
    );
  }

  testWidgets(
    'WebAuthPage renders 50/50 split on desktop and signs in',
    timeout: const Timeout(Duration(seconds: 10)),
    (tester) async {
    final repo = SessionTestRepository();
    final session = SessionCubit(repo);
    final authCubit = AuthCubit(repo, session: session);
    addTearDown(() async {
      await authCubit.close();
      await session.close();
      await repo.dispose();
    });

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildHarness(
        mode: WebAuthMode.login,
        authCubit: authCubit,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Row), findsWidgets);
    expect(find.text('Log In'), findsNWidgets(2));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'nour@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.attempts, 1);
    expect(session.state.user, isNotNull);
  });

  testWidgets('WebAuthPage collapses cleanly on narrow viewport and supports 2-step signup', (
    tester,
  ) async {
    final repo = SessionTestRepository();
    final authCubit = AuthCubit(repo);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildHarness(
        mode: WebAuthMode.register,
        authCubit: authCubit,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextFormField).at(0), 'Nour');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'nour@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Pick the look that represents you.'), findsOneWidget);

    await authCubit.close();
    await repo.dispose();
  });
}
