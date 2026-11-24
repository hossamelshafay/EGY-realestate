import 'package:dio/dio.dart';

import 'package:egy/core/errors/failures.dart';

/// Maps transport and decoding errors to domain failures without server details.
Future<T> guardApi<T>(Future<T> Function() action) async {
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

/// Strict readers for the JSON boundary; absent values never become defaults.
abstract final class ApiJson {
  static Map<String, Object?> object(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static List<Object?> list(Object? value) {
    if (value is! List<Object?>) throw const FormatException('Expected list');
    return value;
  }

  static String string(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Expected text');
    }
    return value;
  }

  static double number(Object? value) {
    if (value is! num || !value.isFinite || value < 0) {
      throw const FormatException('Expected nonnegative number');
    }
    return value.toDouble();
  }

  static int integer(Object? value) {
    final result = number(value);
    if (result != result.truncateToDouble()) {
      throw const FormatException('Expected integer');
    }
    return result.toInt();
  }
}
