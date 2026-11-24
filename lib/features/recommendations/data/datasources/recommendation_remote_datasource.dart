import 'package:egy/core/constants/api_constants.dart';
import 'package:egy/core/network/api_client.dart';
import 'package:egy/core/network/api_result.dart';
import 'package:egy/features/properties/data/models/property_listing_model.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import '../../domain/entities/recommendation_search.dart';

/// HTTP and decoding boundary for recommendations.
class RecommendationRemoteDatasource {
  RecommendationRemoteDatasource(this.client);
  final ApiClient client;

  List<PropertyListing> _items(Map<String, Object?> body) {
    if (body['status'] != 'success') {
      throw const FormatException('Unsuccessful recommendations');
    }
    final items = ApiJson.list(
      body['items'],
    ).map((item) => PropertyListingModel.decode(item)).toList();
    if (items.map((item) => item.id).toSet().length != items.length) {
      throw const FormatException('Duplicate recommendations');
    }
    return List.unmodifiable(items);
  }

  Future<RecommendationSearch> search(RecommendationQuery query) async {
    final body = ApiJson.object(
      await client.request(
        ApiConstants.recommendationsSearch,
        data: {
          'category': query.category,
          'property_type': query.propertyType,
          'city': query.city,
          if (query.minPrice != null) 'min_price': query.minPrice,
          if (query.maxPrice != null) 'max_price': query.maxPrice,
          'limit': query.limit,
          'offset': query.offset,
        },
      ),
    );
    final items = _items(body);
    final total = ApiJson.integer(body['total']);
    if (ApiJson.integer(body['limit']) != query.limit ||
        ApiJson.integer(body['offset']) != query.offset ||
        items.length > query.limit ||
        total < items.length) {
      throw const FormatException('Invalid pagination');
    }
    return RecommendationSearch(
      total: total,
      limit: query.limit,
      offset: query.offset,
      items: items,
    );
  }

  Future<List<PropertyListing>> similar(int propertyId, int limit) async {
    final body = ApiJson.object(
      await client.request(
        '${ApiConstants.recommendationsSimilar}/$propertyId?top_n=$limit',
      ),
    );
    final items = _items(body);
    if (ApiJson.integer(body['property_id']) != propertyId ||
        items.length > limit ||
        items.any((item) => item.id == propertyId)) {
      throw const FormatException('Invalid neighbors');
    }
    return items;
  }
}
