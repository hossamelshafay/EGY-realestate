import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/session_page.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/catalog_repository.dart';
import '../../support/favorites_repository.dart';
import '../../support/session_repository.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => sl.reset());

  for (final dark in [false, true]) {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      for (final width in [360.0, 720.0]) {
        testWidgets(
          'Home curved header background matches canvas seamlessly (dark=$dark, locale=${locale.languageCode}, width=$width)',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            registerTestHome();
            final session = SessionCubit(
              SessionTestRepository()..restore(null),
            );
            final favorites = TestFavoritesRepository();
            sl.registerSingleton<SessionCubit>(session);
            sl.registerFactory<AuthCubit>(
              () => AuthCubit(SessionTestRepository(), session: session),
            );
            sl.registerSingleton<FavoritesCubit>(
              FavoritesCubit(favorites, session),
            );

            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                locale: locale,
                localizationsDelegates: AppLocalizationConfig.delegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SessionPage(),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 500));

            final handoffBg = tester.widget<ColoredBox>(
              find.descendant(
                of: find.byKey(const Key('handoff_background')),
                matching: find.byType(ColoredBox),
              ),
            );
            final homeCanvas = tester.widget<ColoredBox>(
              find.byKey(const Key('home_canvas')),
            );
            final expected = dark ? AppColors.darkCanvas : AppColors.offWhite;
            expect(handoffBg.color, expected);
            expect(homeCanvas.color, expected);
            expect(handoffBg.color, homeCanvas.color);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            await favorites.close();
            await session.close();
            await sl.reset();
          },
        );
      }
    }
  }

  for (final dark in [false, true]) {
    testWidgets(
      'AuthenticatedScaffold uses seamless surface behind concave header (dark=$dark)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: AppLocalizationConfig.delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AuthenticatedScaffold(
              title: 'Profile',
              child: SizedBox.expand(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(
          scaffold.backgroundColor,
          dark ? AppColors.darkSurface : AppColors.white,
        );
        expect(find.byKey(const Key('authenticated_header')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
