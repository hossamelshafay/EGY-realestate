import 'package:egy/features/properties/domain/entities/property_listing.dart';

abstract interface class FavoritesRepository {
  Stream<List<PropertyListing>> watch(String uid);
  Future<void> save(String uid, PropertyListing property);
  Future<void> remove(String uid, int propertyId);
}
