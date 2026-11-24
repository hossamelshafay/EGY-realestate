import 'package:egy/core/network/api_result.dart';
import '../../domain/entities/property_listing.dart';

/// Decodes common catalog fields, preserving missing chat values.
abstract final class PropertyListingModel {
  static Map<String, Object?> encode(PropertyListing item) => {
    'id': item.id,
    'title': item.title,
    'category': item.category,
    'property_type': item.propertyType,
    'location': item.location,
    'city': item.city,
    'price': item.price,
    'size': item.size,
    'bedrooms': item.bedrooms,
    'bathrooms': item.bathrooms,
    'image_url': item.imageUrl,
  };

  static PropertyListing decode(Object? value, {bool allowMissing = false}) {
    final body = ApiJson.object(value);
    double? number(String key) =>
        body[key] == null && allowMissing ? null : ApiJson.number(body[key]);
    final image = body['image_url'];
    if (image != null && image is! String) {
      throw const FormatException('Invalid image URL');
    }
    return PropertyListing(
      id: ApiJson.integer(body['id']),
      title: ApiJson.string(body['title']),
      category: ApiJson.string(body['category']),
      propertyType: ApiJson.string(body['property_type']),
      location: ApiJson.string(body['location']),
      price: number('price'),
      size: number('size'),
      bedrooms: number('bedrooms'),
      bathrooms: number('bathrooms'),
      imageUrl: image as String?,
      city: body['city'] as String?,
    );
  }
}
