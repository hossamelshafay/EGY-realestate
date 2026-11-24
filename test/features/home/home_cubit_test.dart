import 'package:flutter_test/flutter_test.dart';

import 'package:egy/features/home/presentation/cubit/home_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';

import '../../support/catalog_repository.dart';

void main() {
  test(
    'query, city and type refine the current sample without changing it',
    () async {
      final cubit = HomeCubit();
      final items = [
        for (var i = 1; i <= 3; i++)
          testListing(i, PropertyCategory.residentialSale),
      ];
      expect(cubit.state.filter(items), hasLength(3));
      cubit.search('  Cairo ');
      cubit.filterType('Apartment');
      cubit.filterLocation('Cairo');
      expect(cubit.state.filter(items).map((item) => item.id), [1, 3]);
      final original = cubit.state;
      cubit.filterLocation('Giza');
      expect(cubit.state.filter(items), isEmpty);
      expect(original.filter(items), hasLength(2));
      cubit.clearFilters();
      expect(cubit.state.filter(items), hasLength(3));
      expect(items, hasLength(3));
      await cubit.close();
    },
  );
}
