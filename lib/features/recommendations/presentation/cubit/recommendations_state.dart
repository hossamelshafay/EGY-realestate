import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';

/// Immutable recommendation screen state.
sealed class RecommendationsState {
  const RecommendationsState();
}

final class RecommendationsInitial extends RecommendationsState {
  const RecommendationsInitial();
}

final class RecommendationsLoading extends RecommendationsState {
  const RecommendationsLoading();
}

final class RecommendationsReady extends RecommendationsState {
  RecommendationsReady(
    List<PropertyListing> items, {
    required this.total,
    this.loadingMore = false,
    this.failure,
    this.similar = false,
  }) : items = List.unmodifiable(items);
  final List<PropertyListing> items;
  final int total;
  final bool loadingMore, similar;
  final Failure? failure;
}

final class RecommendationsError extends RecommendationsState {
  const RecommendationsError(this.failure);
  final Failure failure;
}
