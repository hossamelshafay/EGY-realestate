import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/prediction_repository.dart';
import 'prediction_state.dart';

export 'prediction_state.dart';

/// Owns loaded vocabulary, selections, submission and result.
class PredictionCubit extends Cubit<PredictionState> {
  PredictionCubit(this.repository) : super(const PredictionInitial());
  final PredictionRepository repository;

  /// Clears selections and the result while retaining the fitted vocabulary.
  void reset() {
    final current = state;
    if (current is PredictionReady && !current.submitting) {
      emit(PredictionReady(current.options));
    }
  }

  Future<void> load() async {
    if (state is PredictionLoading) return;
    emit(const PredictionLoading());
    try {
      final options = await repository.options();
      if (!isClosed) emit(PredictionReady(options));
    } on Failure catch (failure) {
      if (!isClosed) emit(PredictionError(failure));
    }
  }

  void select({String? category, String? propertyType}) {
    final current = state;
    if (current is! PredictionReady || current.submitting) return;
    emit(
      PredictionReady(
        current.options,
        category: category ?? current.category,
        propertyType: propertyType ?? current.propertyType,
      ),
    );
  }

  Future<void> predict(PredictionInput input) async {
    final current = state;
    if (current is! PredictionReady || current.submitting) return;
    emit(
      PredictionReady(
        current.options,
        category: current.category,
        propertyType: current.propertyType,
        submitting: true,
      ),
    );
    try {
      final result = await repository.predict(input);
      if (!isClosed) {
        emit(
          PredictionReady(
            current.options,
            category: current.category,
            propertyType: current.propertyType,
            result: result,
          ),
        );
      }
    } on Failure catch (failure) {
      if (!isClosed) {
        emit(
          PredictionReady(
            current.options,
            category: current.category,
            propertyType: current.propertyType,
            failure: failure,
          ),
        );
      }
    }
  }
}
