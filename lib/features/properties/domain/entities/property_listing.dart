/// Shared catalog facts. Similarity is excluded because it is not confidence.
class PropertyListing {
  const PropertyListing({
    required this.id,
    required this.title,
    required this.category,
    required this.propertyType,
    required this.location,
    this.price,
    this.size,
    this.bedrooms,
    this.bathrooms,
    this.imageUrl,
    this.city,
  });

  final int id;
  final String title, category, propertyType, location;
  final double? price, size, bedrooms, bathrooms;
  final String? imageUrl;
  final String? city;
}
