import 'package:flutter_test/flutter_test.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/network/api_client.dart';
import 'package:egy/features/price_prediction/data/datasources/prediction_remote_datasource.dart';
import 'package:egy/features/price_prediction/data/repositories/prediction_repository_impl.dart';
import 'package:egy/features/price_prediction/domain/entities/prediction.dart';

class RecordingClient extends ApiClient {
  RecordingClient() : super(baseUrl: '', idToken: () async => null);
  Object? response;
  Map<String, Object?>? sent;
  int calls = 0;
  Failure? failure;
  @override
  Future<Object?> request(String path, {Map<String, Object?>? data}) async {
    calls++;
    sent = data;
    if (failure != null) throw failure!;
    return response;
  }
}

PredictionInput input({double size = 130}) => PredictionInput(
  size: size,
  bedrooms: 3,
  bathrooms: 2,
  latitude: 30.03,
  longitude: 31.47,
  propertyType: 'Apartment',
  category: 'buy',
);

void main() {
  late RecordingClient client;
  late PredictionRepositoryImpl repository;
  setUp(() {
    client = RecordingClient();
    repository = PredictionRepositoryImpl(PredictionRemoteDatasource(client));
  });

  test(
    'sends exactly seven features and decodes the heuristic contract',
    () async {
      client.response = <String, Object?>{
        'predicted_price': 1000000,
        'range_low': 925000,
        'range_high': 1075000,
        'currency': 'EGP',
        'meter_price': 7692,
        'range_method': 'heuristic_plus_minus_8_percent_rounded',
        'confidence_pct': 99,
        'shap_breakdown': ['untrusted'],
      };
      final result = await repository.predict(input());
      expect(result.price, 1000000);
      expect(client.sent, {
        'size': 130.0,
        'bedrooms': 3.0,
        'bathrooms': 2.0,
        'latitude': 30.03,
        'longitude': 31.47,
        'property_type': 'Apartment',
        'category': 'buy',
      });
    },
  );

  test('invalid numeric values never reach HTTP', () async {
    for (final value in [double.nan, double.infinity, -1.0, 10001.0]) {
      await expectLater(
        repository.predict(input(size: value)),
        throwsA(isA<ServerFailure>()),
      );
    }
    expect(client.calls, 0);
  });

  test('malformed responses fail rather than defaulting fields', () async {
    client.response = {'predicted_price': 42};
    await expectLater(
      repository.predict(input()),
      throwsA(isA<ServerFailure>()),
    );
    client.response = {
      'categories': {
        'property_type': [],
        'category': ['buy'],
      },
    };
    await expectLater(repository.options(), throwsA(isA<ServerFailure>()));
  });

  test('authentication failure is preserved', () async {
    client.failure = const UnauthenticatedFailure();
    await expectLater(
      repository.predict(input()),
      throwsA(isA<UnauthenticatedFailure>()),
    );
  });
}
