import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/router/session_redirect.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/core/web/web_app_shell.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/authentication/web/pages/web_auth_page.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/home/presentation/cubit/home_search_cubit.dart';
import 'package:egy/features/home/web/pages/web_home_page.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/domain/repositories/catalog_repository.dart';
import 'package:egy/features/recommendations/domain/entities/recommendation_search.dart';
import 'package:egy/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/catalog_repository.dart';
import '../../support/favorites_repository.dart';
import '../../support/session_repository.dart';

class _FakeRecommendationRepo implements RecommendationRepository {
  @override
  Future<RecommendationSearch> search(RecommendationQuery query) async =>
      RecommendationSearch(total: 0, limit: query.limit, offset: 0, items: []);

  @override
  Future<List<PropertyListing>> similar(int propertyId, {int limit = 10}) async =>
      const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const user = AuthUser(
    id: 'u1',
    email: 'test@egy.com',
    name: 'Hossam',
    avatarId: 'atlas',
  );
  late SharedPreferences prefs;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('sessionRedirect platform separation', () {
    test('Web skips splash and onboarding when unauthenticated', () {
      const signedOut = SessionReady();
      expect(
        sessionRedirect(signedOut, RoutePaths.splash, isWeb: true),
        RoutePaths.login,
      );
      expect(
        sessionRedirect(signedOut, RoutePaths.onboarding, isWeb: true),
        RoutePaths.login,
      );
    });

    test('Web skips splash, onboarding, and auth when authenticated', () {
      const signedIn = SessionReady(user: user);
      expect(
        sessionRedirect(signedIn, RoutePaths.splash, isWeb: true),
        RoutePaths.home,
      );
      expect(
        sessionRedirect(signedIn, RoutePaths.onboarding, isWeb: true),
        RoutePaths.home,
      );
      expect(
        sessionRedirect(signedIn, RoutePaths.login, isWeb: true),
        RoutePaths.home,
      );
    });

    test('Mobile preserves splash and onboarding routes', () {
      const signedOut = SessionReady();
      expect(
        sessionRedirect(signedOut, RoutePaths.splash, isWeb: false),
        isNull,
      );
      expect(
        sessionRedirect(signedOut, RoutePaths.onboarding, isWeb: false),
        isNull,
      );
    });
  });

  testWidgets(
    'Web GoRouter provides SessionCubit to WebAppShell across login, home, refresh, and logout',
    (tester) async {
      await sl.reset();
      final authRepo = SessionTestRepository();
      final session = SessionCubit(authRepo);
      final favRepo = TestFavoritesRepository();
      final favorites = FavoritesCubit(favRepo, session);
      final catalogRepo = TestCatalogRepository();
      final recRepo = _FakeRecommendationRepo();

      sl.registerSingleton<AuthRepository>(authRepo);
      sl.registerSingleton<SessionCubit>(session);
      sl.registerFactory<AuthCubit>(() => AuthCubit(authRepo, session: session));
      sl.registerSingleton<FavoritesCubit>(favorites);
      sl.registerSingleton<CatalogRepository>(catalogRepo);
      sl.registerFactory<HomeSearchCubit>(() => HomeSearchCubit(recRepo));

      addTearDown(() async {
        await sl.reset();
        await favorites.close();
        await favRepo.close();
        await session.close();
        await authRepo.dispose();
      });

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = createAppRouter(
        session: session,
        initialLocation: RoutePaths.splash,
        isWeb: true,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(prefs)),
            BlocProvider(create: (_) => LocaleCubit(prefs)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: router,
            localizationsDelegates: AppLocalizationConfig.delegates,
            supportedLocales: LocaleCubit.supportedLocales,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Unauthenticated Web redirects '/' -> '/login'
      expect(find.byType(WebAuthPage), findsOneWidget);

      // Simulate Firebase session restoration / login
      authRepo.restore(user);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // WebAppShell + WebHomePage render with SessionCubit provided (no ProviderNotFoundException or overflow)
      expect(find.byType(WebAppShell), findsOneWidget);
      expect(find.byType(WebHomePage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WebAppShell),
          matching: find.text('EGY Development'),
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome, Hossam'), findsOneWidget);

      // Logout redirects back to '/login'
      await session.signOut();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(WebAuthPage), findsOneWidget);
    },
  );
}
