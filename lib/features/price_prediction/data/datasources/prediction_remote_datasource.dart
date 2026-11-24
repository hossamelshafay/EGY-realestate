import 'package:egy/core/constants/api_constants.dart';
import 'package:egy/core/network/api_client.dart';

import '../../domain/entities/prediction.dart';

/// Typed request/response boundary for the price endpoints.
class PredictionRemoteDatasource {
  PredictionRemoteDatasource(this.client);
  final ApiClient client;

  Map<String, Object?> _map(Object? value) {
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Expected JSON object');
    }
    return Map<String, Object?>.from(value);
  }

  List<String> _strings(Object? value) {
    if (value is! List<Object?> ||
        value.isEmpty ||
        value.any((v) => v is! String)) {
      throw const FormatException('Missing model vocabulary');
    }
    return value.cast<String>();
  }

  /// Fetches categorical choices from the saved model.
  Future<PredictionOptions> options() async {
    final body = _map(await client.request(ApiConstants.predictOptions));
    final categories = _map(body['categories']);
    return PredictionOptions(
      propertyTypes: _strings(categories['property_type']),
      categories: _strings(categories['category']),
    );
  }

  /// Sends seven explicit features; ignores unsupported explanation fields.
  Future<Prediction> predict(PredictionInput input) async {
    final body = _map(
      await client.request(
        ApiConstants.predict,
        data: {
          'size': input.size,
          'bedrooms': input.bedrooms,
          'bathrooms': input.bathrooms,
          'latitude': input.latitude,
          'longitude': input.longitude,
          'property_type': input.propertyType,
          'category': input.category,
        },
      ),
    );
    double number(String key) {
      final value = body[key];
      if (value is! num || !value.isFinite || value < 0) {
        throw FormatException('Invalid $key');
      }
      return value.toDouble();
    }

    final currency = body['currency'];
    if (!['EGP', 'EGP/month'].contains(currency) ||
        body['range_method'] != 'heuristic_plus_minus_8_percent_rounded') {
      throw const FormatException('Unsupported prediction contract');
    }
    final price = number('predicted_price');
    final low = number('range_low'), high = number('range_high');
    if (price <= 0 || low > price || high < price) {
      throw const FormatException('Invalid price range');
    }
    return Prediction(
      price: price,
      low: low,
      high: high,
      currency: currency as String,
      meterPrice: number('meter_price'),
    );
  }
}
