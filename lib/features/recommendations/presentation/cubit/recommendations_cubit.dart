import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/recommendation_search.dart';
import '../../domain/repositories/recommendation_repository.dart';
import 'recommendations_state.dart';
export 'recommendations_state.dart';

/// Owns filters, pagination and stale-request protection.
class RecommendationsCubit extends Cubit<RecommendationsState> {
  RecommendationsCubit(this.repository) : super(const RecommendationsInitial());
  final RecommendationRepository repository;
  RecommendationQuery _query = const RecommendationQuery();
  int _revision = 0;
  int? _similarTo;

  Future<void> search([RecommendationQuery? query]) async {
    _query = query ?? _query;
    _similarTo = null;
    final revision = ++_revision;
    emit(const RecommendationsLoading());
    try {
      final page = await repository.search(_query);
      if (!isClosed && revision == _revision) {
        emit(RecommendationsReady(page.items, total: page.total));
      }
    } on Failure catch (failure) {
      if (!isClosed && revision == _revision) {
        emit(RecommendationsError(failure));
      }
    }
  }

  Future<void> more() async {
    final current = state;
    if (current is! RecommendationsReady ||
        current.loadingMore ||
        current.similar ||
        current.items.length >= current.total) {
      return;
    }
    final revision = _revision;
    emit(
      RecommendationsReady(
        current.items,
        total: current.total,
        loadingMore: true,
      ),
    );
    try {
      final page = await repository.search(
        RecommendationQuery(
          category: _query.category,
          propertyType: _query.propertyType,
          city: _query.city,
          minPrice: _query.minPrice,
          maxPrice: _query.maxPrice,
          limit: _query.limit,
          offset: current.items.length,
        ),
      );
      if (!isClosed && revision == _revision) {
        final seen = current.items.map((p) => p.id).toSet();
        final additions = page.items.where((p) => seen.add(p.id)).toList();
        if (additions.isEmpty && current.items.length < page.total) {
          throw const ServerFailure('pagination');
        }
        emit(
          RecommendationsReady([
            ...current.items,
            ...additions,
          ], total: page.total),
        );
      }
    } on Failure catch (failure) {
      if (!isClosed && revision == _revision) {
        emit(
          RecommendationsReady(
            current.items,
            total: current.total,
            failure: failure,
          ),
        );
      }
    }
  }

  Future<void> similar(int propertyId) async {
    _similarTo = propertyId;
    final revision = ++_revision;
    emit(const RecommendationsLoading());
    try {
      final items = await repository.similar(propertyId, limit: 20);
      if (!isClosed && revision == _revision) {
        emit(RecommendationsReady(items, total: items.length, similar: true));
      }
    } on Failure catch (failure) {
      if (!isClosed && revision == _revision) {
        emit(RecommendationsError(failure));
      }
    }
  }

  Future<void> retry() => _similarTo == null ? search() : similar(_similarTo!);
}
