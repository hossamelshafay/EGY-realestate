import 'package:egy/features/properties/domain/entities/property_listing.dart';
import '../entities/recommendation_search.dart';

/// Authenticated catalog search and saved hybrid neighbors.
abstract interface class RecommendationRepository {
  Future<RecommendationSearch> search(RecommendationQuery query);
  Future<List<PropertyListing>> similar(int propertyId, {int limit = 6});
}
