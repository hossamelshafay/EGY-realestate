import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/core/widgets/session_page.dart';

import '../../support/catalog_repository.dart';
import '../../support/favorites_repository.dart';
import '../../support/session_repository.dart';

Finder frontCard(int id) => find.descendant(
  of: find.byKey(const Key('home_featured_front')),
  matching: find.byKey(ValueKey('featured_$id')),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  late TestCatalogRepository catalog;
  late SessionTestRepository authentication;
  late SessionCubit session;
  late TestFavoritesRepository favorites;
  setUp(() {
    catalog = registerTestHome();
    authentication = SessionTestRepository(
      user: const AuthUser(id: 'home-user', email: 'test@example.com'),
    );
    session = SessionCubit(authentication);
    favorites = TestFavoritesRepository();
    sl.registerSingleton(
      FavoritesCubit(favorites, session),
      dispose: (cubit) => cubit.close(),
    );
  });
  tearDown(() async {
    await sl.reset();
    await favorites.close();
    await session.close();
    await authentication.dispose();
  });
  Widget scene({
    String code = 'en',
    bool dark = false,
    double scale = 1,
    bool reduced = false,
  }) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: Locale(code),
    localizationsDelegates: AppLocalizationConfig.delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: reduced,
      ),
      child: child!,
    ),
    home: const Scaffold(body: SessionPage()),
  );

  for (final code in ['en', 'ar']) {
    for (final dark in [false, true]) {
      testWidgets(
        'reference content fits 320dp $code${dark ? ' dark' : ' light'}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(scene(code: code, dark: dark));
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pumpAndSettle();
          final banner = find.byKey(const Key('home_assistant_banner'));
          final robot = find.byKey(const Key('home_robot'));
          expect(banner, findsOneWidget);
          expect(
            code == 'ar'
                ? tester.getCenter(robot).dx < tester.getCenter(banner).dx
                : tester.getCenter(robot).dx > tester.getCenter(banner).dx,
            isTrue,
          );
          for (var i = 0; i < 4; i++) {
            expect(find.byKey(ValueKey('home_category_$i')), findsOneWidget);
          }
          expect(find.byKey(const Key('home_tool_price')), findsOneWidget);
          expect(
            find.byKey(const Key('home_tool_recommendations')),
            findsOneWidget,
          );
          final canvas = tester.widget<ColoredBox>(
            find.byKey(const Key('home_canvas')),
          );
          expect(
            canvas.color,
            dark
                ? AppTheme.dark.scaffoldBackgroundColor
                : AppTheme.light.scaffoldBackgroundColor,
          );
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
            find.byKey(const Key('home_featured_pages')),
          );
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();
          final favorite = find.byKey(const Key('favorite_1'));
          expect(tester.widget<IconButton>(favorite).onPressed, isNotNull);
          await tester.tap(favorite);
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<IconButton>(find.byKey(const Key('favorite_1')))
                .isSelected,
            isTrue,
          );
          await tester.drag(
            find.byKey(const Key('home_featured_pages')),
            Offset(code == 'ar' ? 260 : -260, 0),
          );
          await tester.pumpAndSettle();
          expect(frontCard(2), findsOneWidget);
          await tester.drag(
            find.byKey(const Key('home_featured_pages')),
            Offset(code == 'ar' ? -260 : 260, 0),
          );
          await tester.pumpAndSettle();
          expect(frontCard(1), findsOneWidget);
          await tester.ensureVisible(find.byKey(const Key('home_search')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('home_search')));
          await tester.pumpAndSettle();
          final query = find.byKey(const Key('home_search_query'));
          expect(tester.widget<TextField>(query).controller!.text, isEmpty);
          expect(find.byKey(const Key('home_search_result_1')), findsOneWidget);
          await tester.enterText(query, 'no such home');
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('home_search_close')));
          await tester.pumpAndSettle();
          expect(query, findsNothing);
          expect(find.byKey(const Key('home_featured_pages')), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'carousel advances, retains its position across prefetch and pauses for touch and background',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(scene());
      await tester.pumpAndSettle();
      final strip = find.byKey(const Key('home_featured_pages'));
      await tester.ensureVisible(strip);
      await tester.pumpAndSettle();
      final progress = find.byKey(const Key('home_featured_progress'));
      double elapsed() =>
          tester.widget<LinearProgressIndicator>(progress).value!;
      expect(frontCard(1), findsOneWidget);
      final front = tester.getRect(frontCard(1));
      final behind = tester.getRect(find.byKey(const ValueKey('featured_2')));
      expect(front.intersect(behind).width, greaterThan(front.width * .9));
      expect(behind.right - front.right, closeTo(16, .1));

      Future<void> advance() async {
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }

      final initialProgress = elapsed();
      await tester.pump(const Duration(seconds: 3));
      expect(frontCard(1), findsOneWidget);
      expect(elapsed() - initialProgress, closeTo(.6, .03));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(frontCard(2), findsOneWidget);
      expect(elapsed(), lessThan(.15));
      final touch = await tester.startGesture(tester.getCenter(strip));
      await advance();
      expect(frontCard(2), findsOneWidget);
      await touch.up();
      await advance();
      expect(frontCard(3), findsOneWidget);
      expect(catalog.requests[1].$2, 5);
      expect(catalog.requests[1].$3, unorderedEquals([1, 2, 3, 4, 5]));
      expect(frontCard(3), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await advance();
      expect(frontCard(3), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      for (var page = 3; page <= 6; page++) {
        await advance();
        expect(frontCard(page + 1), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('featured_7')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'category updates the active sample and scaled RTL remains usable',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(scene(code: 'ar', scale: 1.6, reduced: true));
      await tester.pumpAndSettle();
      final category = find.byKey(const Key('home_category_2'));
      await tester.ensureVisible(category);
      await tester.pumpAndSettle();
      await tester.tap(category);
      await tester.pumpAndSettle();
      expect(catalog.requests.last.$1, PropertyCategory.commercialSale);
      expect(catalog.requests.last.$2, 5);
      expect(find.byKey(const Key('featured_201')), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('home_featured_pages')));
      await tester.pumpAndSettle();
      final stack = find.byKey(const Key('home_featured_pages'));
      expect(find.byKey(const Key('home_featured_progress')), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      expect(frontCard(201), findsOneWidget);
      for (final id in [202, 203]) {
        await tester.drag(stack, const Offset(220, 0));
        await tester.pumpAndSettle();
        expect(frontCard(id), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
