import 'package:dio/dio.dart';
import 'package:egy/core/errors/failures.dart';

import '../../domain/entities/prediction.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../datasources/prediction_remote_datasource.dart';

/// Converts transport, validation and decoding exceptions into domain failures.
class PredictionRepositoryImpl implements PredictionRepository {
  PredictionRepositoryImpl(this.source);
  final PredictionRemoteDatasource source;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Failure {
      rethrow;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const UnauthenticatedFailure();
      }
      if (status != null) throw ServerFailure('http', statusCode: status);
      throw const NetworkFailure();
    } on FormatException {
      throw const ServerFailure('response');
    } catch (_) {
      throw const ServerFailure('unknown');
    }
  }

  @override
  Future<PredictionOptions> options() => _guard(source.options);

  @override
  Future<Prediction> predict(PredictionInput input) => _guard(() {
    if (!input.isValid) throw const ServerFailure('input', statusCode: 422);
    return source.predict(input);
  });
}
