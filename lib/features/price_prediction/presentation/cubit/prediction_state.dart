import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/prediction.dart';

/// Immutable state of the prediction form and request.
sealed class PredictionState {
  const PredictionState();
}

final class PredictionInitial extends PredictionState {
  const PredictionInitial();
}

final class PredictionLoading extends PredictionState {
  const PredictionLoading();
}

final class PredictionReady extends PredictionState {
  const PredictionReady(
    this.options, {
    this.category,
    this.propertyType,
    this.result,
    this.failure,
    this.submitting = false,
  });
  final PredictionOptions options;
  final String? category, propertyType;
  final Prediction? result;
  final Failure? failure;
  final bool submitting;
}

final class PredictionError extends PredictionState {
  const PredictionError(this.failure);
  final Failure failure;
}
