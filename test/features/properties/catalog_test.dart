import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/app/app.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/router/app_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';

import '../../support/catalog_repository.dart';
import '../../support/session_repository.dart';

class DelayedCatalog extends TestCatalogRepository {
  final first = Completer<List<PropertyListing>>();

  @override
  Future<List<PropertyListing>> sample(
    PropertyCategory category, {
    required int limit,
    List<int> excluding = const [],
  }) => category == PropertyCategory.residentialSale
      ? first.future
      : super.sample(category, limit: limit, excluding: excluding);
}

class DelayedAppendCatalog extends TestCatalogRepository {
  final next = Completer<List<PropertyListing>>();

  @override
  Future<List<PropertyListing>> sample(
    PropertyCategory category, {
    required int limit,
    List<int> excluding = const [],
  }) => category == PropertyCategory.residentialSale && excluding.isNotEmpty
      ? next.future
      : super.sample(category, limit: limit, excluding: excluding);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => sl.reset());

  test(
    'a slower category response cannot overwrite the current sample',
    () async {
      final repository = DelayedCatalog();
      final cubit = CatalogCubit(
        repository,
        PropertyCategory.residentialSale,
        limit: 5,
      );
      final old = cubit.refresh();
      await cubit.select(PropertyCategory.commercialRent);
      repository.first.complete([
        testListing(1, PropertyCategory.residentialSale),
      ]);
      await old;
      expect(cubit.state.category, PropertyCategory.commercialRent);
      expect((cubit.state as CatalogReady).items, hasLength(5));
      await cubit.close();
    },
  );

  test(
    'prefetch retains visible cards and discards a late category batch',
    () async {
      final repository = DelayedAppendCatalog();
      final cubit = CatalogCubit(
        repository,
        PropertyCategory.residentialSale,
        limit: 5,
      );
      await cubit.refresh();
      final original = cubit.state;
      final append = cubit.prefetch((_) => true);
      expect(cubit.state, same(original));
      await cubit.select(PropertyCategory.commercialRent);
      repository.next.complete([
        testListing(6, PropertyCategory.residentialSale),
      ]);
      await append;
      final current = cubit.state as CatalogReady;
      expect(current.category, PropertyCategory.commercialRent);
      expect(current.items.map((item) => item.id), [301, 302, 303, 304, 305]);
      await cubit.close();
    },
  );

  test(
    'prefetch appends only unseen IDs when the server returns fallback rows',
    () async {
      final category = PropertyCategory.residentialSale;
      final repository = DelayedAppendCatalog();
      final cubit = CatalogCubit(repository, category, limit: 5);
      await cubit.refresh();
      final append = cubit.prefetch((_) => true);
      repository.next.complete(
        [1, 3, 6, 7, 8].map((id) => testListing(id, category)).toList(),
      );
      await append;
      expect((cubit.state as CatalogReady).items.map((item) => item.id), [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
      ]);
      await cubit.close();
    },
  );

  testWidgets(
    'Home opens View All in the selected category and refresh stays there',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final catalog = registerTestHome();
      final auth = SessionTestRepository(
        user: const AuthUser(id: 'catalog-user', email: 'test@example.com'),
      );
      final session = SessionCubit(auth);
      sl.registerSingleton(session);
      final router = createAppRouter(
        session: session,
        initialLocation: RoutePaths.home,
      );
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        App(prefs: await SharedPreferences.getInstance(), router: router),
      );
      await tester.pumpAndSettle();

      final category = find.byKey(const Key('home_category_3'));
      await tester.ensureVisible(category);
      await tester.tap(category);
      await tester.pumpAndSettle();
      final all = find.byKey(const Key('home_view_all'));
      await tester.ensureVisible(all);
      await tester.tap(all);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, RoutePaths.propertyCatalog);
      expect(router.state.uri.queryParameters['category'], 'commercial_rent');
      expect(catalog.requests.last.$1, PropertyCategory.commercialRent);
      expect(catalog.requests.last.$2, 15);
      expect(catalog.requests.last.$3, isEmpty);
      final list = find.byKey(const Key('property_catalog_list'));
      int? length() =>
          tester.widget<ListView>(list).childrenDelegate.estimatedChildCount;
      expect(length(), 15);
      expect(find.byKey(const ValueKey('listing_301')), findsOneWidget);

      await tester.drag(list, const Offset(0, 380));
      await tester.pumpAndSettle();
      expect(catalog.requests.last.$1, PropertyCategory.commercialRent);
      expect(catalog.requests.last.$2, 15);
      expect(catalog.requests.last.$3, List.generate(15, (i) => 301 + i));
      expect(length(), 15);
      expect(find.byKey(const ValueKey('listing_316')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await tester.runAsync(() async {
        await session.close();
        await auth.dispose();
      });
    },
  );
}
