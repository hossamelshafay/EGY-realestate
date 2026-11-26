import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:egy/features/home/presentation/cubit/home_search_cubit.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/recommendations/domain/entities/recommendation_search.dart';

import '../../support/catalog_repository.dart';

class _DelayedSearchRepository extends TestHomeSearchRepository {
  final requests = <(RecommendationQuery, Completer<RecommendationSearch>)>[];

  @override
  Future<RecommendationSearch> search(RecommendationQuery query) {
    final result = Completer<RecommendationSearch>();
    requests.add((query, result));
    return result.future;
  }
}

void main() {
  test(
    'suggestions are real, localized, deduplicated and latest-query only',
    () async {
      const category = PropertyCategory.residentialSale;
      final repository = _DelayedSearchRepository();
      final cubit = HomeSearchCubit(repository);
      addTearDown(cubit.close);
      final sample = testListing(1, category);

      void query(String text) => cubit.search(
        text: text,
        category: category,
        sample: [sample],
        typeLabels: const {'apartment': 'Apartment', 'شقة': 'Apartment'},
        type: null,
        city: null,
        immediate: true,
      );

      query('');
      expect(cubit.state.items, [sample]);
      expect(repository.requests, isEmpty);

      query('Cairo [1]');
      expect(repository.requests.first.$1.city, r'(?:cairo \[1\])');

      query('شقة');
      final (request, pending) = repository.requests.last;
      expect(request.propertyType, 'Apartment');
      expect(request.category, category.code);
      pending.complete(
        RecommendationSearch(
          total: 2,
          limit: request.limit,
          offset: 0,
          items: [testListing(1, category), testListing(3, category)],
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.items.map((item) => item.id), [1, 3]);

      final (stale, stalePending) = repository.requests.first;
      stalePending.complete(
        RecommendationSearch(
          total: 1,
          limit: stale.limit,
          offset: 0,
          items: [testListing(9, category)],
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.items.map((item) => item.id), [1, 3]);
    },
  );
}
