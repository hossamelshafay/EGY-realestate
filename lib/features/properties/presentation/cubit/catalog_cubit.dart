import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/core/errors/failures.dart';

import '../../domain/entities/property_category.dart';
import '../../domain/entities/property_listing.dart';
import '../../domain/repositories/catalog_repository.dart';

sealed class CatalogState {
  const CatalogState(this.category);
  final PropertyCategory category;
}

final class CatalogLoading extends CatalogState {
  const CatalogLoading(super.category);
}

final class CatalogReady extends CatalogState {
  const CatalogReady(super.category, this.items, {this.exhausted = false});
  final List<PropertyListing> items;
  final bool exhausted;
}

final class CatalogError extends CatalogState {
  const CatalogError(super.category, this.failure);
  final Failure failure;
}

/// Samples single-category pages and discards superseded results.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(
    this._repository,
    PropertyCategory category, {
    required this.limit,
  }) : super(CatalogLoading(category));

  final CatalogRepository _repository;
  final int limit;
  int _request = 0;
  int? _refreshing, _prefetching;
  List<int> _shown = const [];

  Future<void> select(PropertyCategory category) async {
    if (category == state.category) return;
    _shown = const [];
    await _load(category);
  }

  Future<void> refresh() => _load(state.category);

  Future<void> _load(PropertyCategory category) async {
    final revision = ++_request;
    _refreshing = revision;
    if (state is! CatalogReady || state.category != category) {
      emit(CatalogLoading(category));
    }
    try {
      final items = await _repository.sample(
        category,
        limit: limit,
        excluding: _shown,
      );
      if (isClosed || revision != _request) return;
      _shown = items.map((item) => item.id).toList(growable: false);
      emit(
        CatalogReady(
          category,
          List.unmodifiable(items),
          exhausted: items.length < limit,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed || revision != _request) return;
      emit(CatalogError(category, failure));
    } finally {
      if (_refreshing == revision) _refreshing = null;
    }
  }

  /// Appends unique listings and keeps the visible page intact on a slow or failed request.
  Future<void> prefetch(bool Function(PropertyListing) matches) async {
    final current = state;
    final revision = _request;
    if (current is! CatalogReady ||
        current.exhausted ||
        _refreshing != null ||
        _prefetching == revision) {
      return;
    }
    _prefetching = revision;
    final items = [...current.items];
    final seen = items.map((item) => item.id).toSet();
    var exhausted = false;
    try {
      // The endpoint filters by category. Bound the extra sampling needed by local filters.
      for (var attempt = 0; attempt < 3; attempt++) {
        final allSeenExcluded = items.length <= 45;
        final batch = await _repository.sample(
          current.category,
          limit: limit,
          excluding: items.reversed.take(45).map((item) => item.id).toList(),
        );
        if (isClosed || revision != _request) return;
        final additions = batch.where((item) => seen.add(item.id)).toList();
        items.addAll(additions);
        // Fallback to recently excluded IDs means the pool ran out of new rows.
        exhausted =
            batch.length < limit || (allSeenExcluded && additions.isEmpty);
        if (exhausted || additions.any(matches)) break;
      }
    } on Failure {
      // A background prefetch leaves the current deck available for a later retry.
    } finally {
      if (_prefetching == revision) _prefetching = null;
    }
    if (isClosed || revision != _request) return;
    if (items.length != current.items.length || exhausted) {
      emit(
        CatalogReady(
          current.category,
          List.unmodifiable(items),
          exhausted: exhausted,
        ),
      );
    }
  }
}
