import '../entities/property_category.dart';
import '../entities/property_listing.dart';

abstract interface class CatalogRepository {
  Future<List<PropertyListing>> sample(
    PropertyCategory category, {
    required int limit,
    List<int> excluding = const [],
  });

  Future<PropertyListing> details(int id);
}
