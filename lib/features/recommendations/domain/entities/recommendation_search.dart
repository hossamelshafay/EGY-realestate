import 'package:egy/features/properties/domain/entities/property_listing.dart';

/// Explicit catalog filters and pagination.
class RecommendationQuery {
  const RecommendationQuery({
    this.category = 'all',
    this.propertyType = 'all',
    this.city = 'all',
    this.minPrice,
    this.maxPrice,
    this.limit = 6,
    this.offset = 0,
  });

  final String category, propertyType, city;
  final double? minPrice, maxPrice;
  final int limit, offset;

  bool get isValid =>
      category.isNotEmpty &&
      propertyType.isNotEmpty &&
      city.isNotEmpty &&
      limit >= 1 &&
      limit <= 100 &&
      offset >= 0 &&
      (minPrice == null || (minPrice!.isFinite && minPrice! >= 0)) &&
      (maxPrice == null || (maxPrice!.isFinite && maxPrice! >= 0)) &&
      (minPrice == null || maxPrice == null || minPrice! <= maxPrice!);
}

/// One immutable page of real listings and the full matching count.
class RecommendationSearch {
  RecommendationSearch({
    required this.total,
    required this.limit,
    required this.offset,
    required List<PropertyListing> items,
  }) : items = List.unmodifiable(items);

  final int total, limit, offset;
  final List<PropertyListing> items;
}
