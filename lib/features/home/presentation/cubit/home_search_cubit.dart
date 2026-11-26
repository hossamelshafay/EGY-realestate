import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/recommendations/domain/entities/recommendation_search.dart';
import 'package:egy/features/recommendations/domain/repositories/recommendation_repository.dart';

sealed class HomeSearchState {
  const HomeSearchState(this.items);
  final List<PropertyListing> items;
}

final class HomeSearchReady extends HomeSearchState {
  const HomeSearchReady(super.items);
}

final class HomeSearchLoading extends HomeSearchState {
  const HomeSearchLoading(super.items);
}

final class HomeSearchError extends HomeSearchState {
  const HomeSearchError(super.items, this.failure);
  final Failure failure;
}

/// Searches the current category with the catalog's location and type filters.
class HomeSearchCubit extends Cubit<HomeSearchState> {
  HomeSearchCubit(this._repository) : super(const HomeSearchReady([]));

  final RecommendationRepository _repository;
  static const _limit = 8;
  Timer? _debounce;
  int _revision = 0;

  void search({
    required String text,
    required PropertyCategory category,
    required List<PropertyListing> sample,
    required Map<String, String> typeLabels,
    required String? type,
    required String? city,
    bool immediate = false,
  }) {
    final revision = ++_revision;
    _debounce?.cancel();
    final query = text.trim().toLowerCase();
    final matchingTypes = {
      for (final entry in typeLabels.entries)
        if (query.length >= 2 && entry.key.startsWith(query)) entry.value,
    };
    final queryType =
        typeLabels[query] ??
        (matchingTypes.length == 1 ? matchingTypes.single : null);
    if (queryType != null && type != null && queryType != type) {
      emit(const HomeSearchReady([]));
      return;
    }
    final local = sample
        .where((item) {
          if (type != null && item.propertyType != type) return false;
          if (city != null && item.city != city) return false;
          return query.isEmpty ||
              [
                item.title,
                item.location,
                item.city,
                item.localizedCity,
                item.propertyType,
              ].whereType<String>().any(
                (value) => value.toLowerCase().contains(query),
              ) ||
              item.propertyType == queryType;
        })
        .take(_limit)
        .toList(growable: false);

    if (query.isEmpty && local.isNotEmpty) {
      emit(HomeSearchReady(local));
      return;
    }
    final knownCity = sample
        .where((item) => item.localizedCity?.toLowerCase() == query)
        .map((item) => item.city)
        .whereType<String>()
        .firstOrNull;
    final location = queryType == null && query.isNotEmpty
        ? (knownCity ?? query)
        : city;
    emit(HomeSearchLoading(local));
    Future<void> fetch() async {
      try {
        final page = await _repository.search(
          RecommendationQuery(
            category: category.code,
            propertyType: type ?? queryType ?? 'all',
            // The server's location filter consumes a regex. Treat input as literal.
            city: location == null ? 'all' : '(?:${RegExp.escape(location)})',
            limit: _limit,
          ),
        );
        if (isClosed || revision != _revision) return;
        final merged = {for (final item in local) item.id: item};
        for (final item in page.items) {
          if (item.category != category.code ||
              (city != null && item.city != city)) {
            continue;
          }
          merged.putIfAbsent(item.id, () => item);
        }
        emit(
          HomeSearchReady(merged.values.take(_limit).toList(growable: false)),
        );
      } on Failure catch (failure) {
        if (!isClosed && revision == _revision) {
          emit(HomeSearchError(local, failure));
        }
      }
    }

    if (immediate) {
      unawaited(fetch());
    } else {
      _debounce = Timer(const Duration(milliseconds: 280), fetch);
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
