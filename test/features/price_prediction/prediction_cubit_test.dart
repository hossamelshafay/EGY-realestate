import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/price_prediction/domain/entities/prediction.dart';
import 'package:egy/features/price_prediction/domain/repositories/prediction_repository.dart';
import 'package:egy/features/price_prediction/presentation/cubit/prediction_cubit.dart';

class PendingRepository implements PredictionRepository {
  final pending = Completer<Prediction>();
  Failure? failure;
  int calls = 0;
  @override
  Future<PredictionOptions> options() async =>
      PredictionOptions(propertyTypes: ['Apartment'], categories: ['buy']);
  @override
  Future<Prediction> predict(PredictionInput input) async {
    calls++;
    if (failure != null) throw failure!;
    return pending.future;
  }
}

const input = PredictionInput(
  size: 130,
  bedrooms: 3,
  bathrooms: 2,
  latitude: 30.03,
  longitude: 31.47,
  propertyType: 'Apartment',
  category: 'buy',
);
const result = Prediction(
  price: 1000000,
  low: 925000,
  high: 1075000,
  currency: 'EGP',
  meterPrice: 7692,
);

void main() {
  test(
    'loads choices without selecting defaults and preserves selections',
    () async {
      final cubit = PredictionCubit(PendingRepository());
      await cubit.load();
      expect((cubit.state as PredictionReady).category, isNull);
      cubit.select(category: 'buy');
      cubit.select(propertyType: 'Apartment');
      final ready = cubit.state as PredictionReady;
      expect(ready.category, 'buy');
      expect(ready.propertyType, 'Apartment');
      await cubit.close();
    },
  );

  test(
    'suppresses duplicate submissions and publishes the repository result',
    () async {
      final repository = PendingRepository();
      final cubit = PredictionCubit(repository);
      await cubit.load();
      final task = cubit.predict(input);
      await cubit.predict(input);
      expect(repository.calls, 1);
      expect((cubit.state as PredictionReady).submitting, isTrue);
      repository.pending.complete(result);
      await task;
      expect((cubit.state as PredictionReady).result, same(result));
      await cubit.close();
    },
  );

  test('preserves failures without fabricating a prediction', () async {
    final repository = PendingRepository()
      ..failure = const ServerFailure('unavailable');
    final cubit = PredictionCubit(repository);
    await cubit.load();
    await cubit.predict(input);
    expect((cubit.state as PredictionReady).result, isNull);
    expect((cubit.state as PredictionReady).failure, repository.failure);
    await cubit.close();
  });

  test('does not emit after being closed during inference', () async {
    final repository = PendingRepository();
    final cubit = PredictionCubit(repository);
    await cubit.load();
    final task = cubit.predict(input);
    await cubit.close();
    repository.pending.complete(result);
    await task;
  });
}
