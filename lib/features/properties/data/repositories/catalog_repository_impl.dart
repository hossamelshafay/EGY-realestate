import 'package:egy/core/constants/api_constants.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/network/api_client.dart';
import 'package:egy/core/network/api_result.dart';

import '../../domain/entities/property_category.dart';
import '../../domain/entities/property_listing.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/property_listing_model.dart';

/// Reads only a bounded sample or a single requested listing.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<PropertyListing>> sample(
    PropertyCategory category, {
    required int limit,
    List<int> excluding = const [],
  }) => guardApi(() async {
    if (limit < 1 || limit > 45 || excluding.length > 45) {
      throw const ServerFailure('input', statusCode: 422);
    }
    final raw = await _client.request(
      ApiConstants.catalogSample,
      data: {
        'category': category.code,
        'limit': limit,
        'exclude_ids': excluding,
      },
    );
    final items = ApiJson.list(raw).map(PropertyListingModel.decode).toList();
    if (items.length > limit ||
        items.map((item) => item.id).toSet().length != items.length ||
        items.any((item) => item.category != category.code)) {
      throw const FormatException('Invalid catalog sample');
    }
    return List.unmodifiable(items);
  });

  @override
  Future<PropertyListing> details(int id) => guardApi(() async {
    final item = PropertyListingModel.decode(
      await _client.request('${ApiConstants.recommendationsById}/$id'),
    );
    if (item.id != id) throw const FormatException('Unexpected listing');
    return item;
  });
}
