import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/core/web/web_app_shell.dart';
import 'package:egy/core/web/web_theme.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/favorites/web/pages/web_favorites_page.dart';
import 'package:egy/features/home/presentation/cubit/home_search_cubit.dart';
import 'package:egy/features/home/web/pages/web_home_page.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';
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
  late SharedPreferences prefs;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  setUp(() async {
    await prefs.clear();
  });

  for (final size in const [
    Size(375, 812),
    Size(768, 1024),
    Size(1280, 800),
    Size(1920, 1080),
  ]) {
    testWidgets(
      'WebAppShell + WebHomePage renders cleanly at $size',
      timeout: const Timeout(Duration(seconds: 15)),
      (tester) async {
      final authRepo = SessionTestRepository(
        user: const AuthUser(
          id: 'u1',
          email: 'nour@example.com',
          name: 'Nour',
          avatarId: 'atlas',
        ),
      );
      final session = SessionCubit(authRepo);
      final favRepo = TestFavoritesRepository();
      final favorites = FavoritesCubit(favRepo, session);
      final catalog = CatalogCubit(
        TestCatalogRepository(),
        PropertyCategory.residentialSale,
        limit: 6,
      )..refresh();
      final search = HomeSearchCubit(_FakeRecommendationRepo());
      addTearDown(() async {
        await search.close();
        await catalog.close();
        await favorites.close();
        await favRepo.close();
        await session.close();
        await authRepo.dispose();
      });

      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(prefs)),
            BlocProvider(create: (_) => LocaleCubit(prefs)),
            BlocProvider.value(value: session),
            BlocProvider.value(value: favorites),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) => MaterialApp(
              theme: WebTheme.light(AppTheme.light),
              darkTheme: WebTheme.dark(AppTheme.dark),
              themeMode: themeState.mode,
              localizationsDelegates: AppLocalizationConfig.delegates,
              supportedLocales: LocaleCubit.supportedLocales,
              home: WebAppShell(
                currentPath: RoutePaths.home,
                child: WebHomePage(
                  catalogCubit: catalog,
                  searchCubit: search,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      if (size.width >= 520) {
        expect(find.text('EGY Development'), findsOneWidget);
      }
      expect(find.text('Welcome, Nour'), findsOneWidget);

      // Verify AI Tools card titles and Navbar controls have readable Light Mode contrast
      final aiTitle = tester.widget<Text>(find.text('Price Predictor'));
      expect(aiTitle.style?.color, isNot(Colors.white));
      expect(find.byType(WebAppShell), findsOneWidget);

      // Verify smooth Web theme toggle without freeze
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });
  }

  testWidgets('WebFavoritesPage renders empty state in Arabic RTL dark mode', (
    tester,
  ) async {
    final authRepo = SessionTestRepository(
      user: const AuthUser(id: 'u1', email: 'nour@example.com', name: 'Nour'),
    );
    final session = SessionCubit(authRepo);
    final favRepo = TestFavoritesRepository();
    final favorites = FavoritesCubit(favRepo, session);
    addTearDown(() async {
      await favorites.close();
      await favRepo.close();
      await session.close();
      await authRepo.dispose();
    });

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(prefs)..select(ThemeMode.dark)),
          BlocProvider(
            create: (_) => LocaleCubit(prefs)..setLocale(const Locale('ar')),
          ),
          BlocProvider.value(value: session),
          BlocProvider.value(value: favorites),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizationConfig.delegates,
          supportedLocales: LocaleCubit.supportedLocales,
          home: const WebAppShell(
            currentPath: RoutePaths.favorites,
            child: WebFavoritesPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WebFavoritesPage), findsOneWidget);
  });
}
