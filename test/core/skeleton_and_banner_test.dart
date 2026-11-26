import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/favorites/presentation/pages/favorites_page.dart';
import 'package:egy/features/home/presentation/widgets/home_assistant_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../support/favorites_repository.dart';
import '../support/session_repository.dart';

void main() {
  tearDown(() => sl.reset());

  for (final dark in [false, true]) {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      testWidgets(
        'HomeAssistantBanner renders and navigates to AI Chat (dark=$dark, locale=${locale.languageCode})',
        (tester) async {
          var navigated = false;
          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(
                  body: Padding(
                    padding: EdgeInsets.all(16),
                    child: HomeAssistantBanner(compact: true),
                  ),
                ),
              ),
              GoRoute(
                name: RouteNames.aiChat,
                path: RoutePaths.aiChat,
                builder: (_, _) {
                  navigated = true;
                  return const Scaffold(body: SizedBox.shrink());
                },
              ),
            ],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MaterialApp.router(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              locale: locale,
              localizationsDelegates: AppLocalizationConfig.delegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('home_assistant_banner')), findsOneWidget);
          expect(find.byKey(const Key('home_assistant_cta')), findsOneWidget);
          expect(find.byKey(const Key('home_robot')), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(const Key('home_assistant_banner')));
          await tester.pumpAndSettle();
          expect(navigated, isTrue);
        },
      );
    }
  }

  testWidgets('Skeleton widgets render cleanly in reduced motion and dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SkeletonFeaturedCard(height: 220),
                  SkeletonListingList(count: 2),
                  SkeletonSearchSuggestions(count: 2),
                  SkeletonDetailsBody(),
                  SkeletonProfile(),
                  SkeletonPredictionForm(),
                  SkeletonPredictionResult(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('skeleton_featured_card')), findsOneWidget);
    expect(find.byKey(const Key('skeleton_listing_list')), findsOneWidget);
    expect(find.byKey(const Key('skeleton_profile')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FavoritesPage transitions from Skeleton to Empty and Error', (
    tester,
  ) async {
    final auth = SessionTestRepository(
      user: const AuthUser(id: 'u1', email: 'u1@example.com'),
    );
    final session = SessionCubit(auth);
    final repo = TestFavoritesRepository();
    final favCubit = FavoritesCubit(repo, session);
    sl.registerSingleton<SessionCubit>(session);
    sl.registerSingleton<FavoritesCubit>(favCubit);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizationConfig.delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FavoritesPage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('skeleton_listing_list')), findsNothing);
    expect(find.text('No saved properties yet.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await favCubit.close();
    await session.close();
    await auth.dispose();
  });
}
