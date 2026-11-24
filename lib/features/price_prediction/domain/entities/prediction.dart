/// Required model inputs, in their original units.
class PredictionInput {
  const PredictionInput({
    required this.size,
    required this.bedrooms,
    required this.bathrooms,
    required this.latitude,
    required this.longitude,
    required this.propertyType,
    required this.category,
  });
  final double size, bedrooms, bathrooms, latitude, longitude;
  final String propertyType, category;

  /// Rejects invalid values before sending them to the server.
  bool get isValid =>
      size.isFinite &&
      size >= 20 &&
      size <= 10000 &&
      bedrooms.isFinite &&
      bedrooms >= 0 &&
      bedrooms <= 20 &&
      bathrooms.isFinite &&
      bathrooms >= 0 &&
      bathrooms <= 20 &&
      latitude.isFinite &&
      latitude >= 22 &&
      latitude <= 32 &&
      longitude.isFinite &&
      longitude >= 24 &&
      longitude <= 38 &&
      propertyType.isNotEmpty &&
      category.isNotEmpty;
}

/// Vocabularies read from the loaded model, with no default selection.
class PredictionOptions {
  PredictionOptions({
    required List<String> propertyTypes,
    required List<String> categories,
  }) : propertyTypes = List.unmodifiable(propertyTypes),
       categories = List.unmodifiable(categories);
  final List<String> propertyTypes, categories;
}

/// Price estimate. The range is heuristic; no confidence or SHAP is asserted.
class Prediction {
  const Prediction({
    required this.price,
    required this.low,
    required this.high,
    required this.currency,
    required this.meterPrice,
  });
  final double price, low, high, meterPrice;
  final String currency;
}
