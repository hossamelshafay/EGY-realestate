import '../entities/prediction.dart';

/// Prediction operations; errors use the shared Failure types.
abstract interface class PredictionRepository {
  Future<PredictionOptions> options();
  Future<Prediction> predict(PredictionInput input);
}
