import 'package:flutter_test/flutter_test.dart';

import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/properties/data/models/property_listing_model.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';

import '../../support/catalog_repository.dart';
import '../../support/favorites_repository.dart';
import '../../support/session_repository.dart';

void main() {
  test(
    'save and remove persist across cubits without leaking across UIDs',
    () async {
      const first = AuthUser(id: 'first', email: 'first@example.com');
      const second = AuthUser(id: 'second', email: 'second@example.com');
      final auth = SessionTestRepository(user: first);
      final session = SessionCubit(auth);
      final repository = TestFavoritesRepository();
      final property = testListing(1, PropertyCategory.residentialSale);
      final roundTrip = PropertyListingModel.decode(
        PropertyListingModel.encode(property),
      );
      expect(roundTrip.propertyType, 'Apartment');
      expect(roundTrip.id, property.id);
      expect(roundTrip.category, 'buy');

      var cubit = FavoritesCubit(repository, session);
      Future<FavoritesReady> next() => cubit.stream
          .where((state) => state is FavoritesReady)
          .cast<FavoritesReady>()
          .first;
      await next();
      var changed = next();
      expect(await cubit.toggle(property), isNull);
      expect((await changed).ids, {1});
      await cubit.close();

      cubit = FavoritesCubit(repository, session);
      expect((await next()).ids, {1});
      changed = next();
      auth.restore(second);
      expect((await changed).ids, isEmpty);
      changed = next();
      auth.restore(first);
      expect((await changed).ids, {1});
      changed = next();
      expect(await cubit.toggle(property), isNull);
      expect((await changed).ids, isEmpty);

      await cubit.close();
      await session.close();
      await auth.dispose();
      await repository.close();
    },
  );
}
