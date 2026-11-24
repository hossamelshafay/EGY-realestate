import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/constants/api_constants.dart';

/// HTTP boundary; obtains a current Firebase ID token for every request.
class ApiClient {
  ApiClient({required this.baseUrl, required this.idToken, Dio? dio})
    : _dio =
          dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  final String baseUrl;
  final Future<String?> Function() idToken;
  final Dio _dio;

  /// Sends JSON only to the explicitly configured backend, without redirects.
  Future<Object?> request(String path, {Map<String, Object?>? data}) async {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        ['localhost', '127.0.0.1', '::1'].contains(uri.host) ||
        (kReleaseMode && uri.scheme != 'https')) {
      throw const ServerFailure('configuration');
    }
    final token = await idToken();
    if (token == null || token.isEmpty) {
      throw const UnauthenticatedFailure();
    }
    final response = await _dio.request<Object?>(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path',
      data: data,
      options: Options(
        method: data == null ? 'GET' : 'POST',
        headers: {'Authorization': 'Bearer $token'},
        contentType: Headers.jsonContentType,
        sendTimeout: Duration(seconds: path == ApiConstants.chat ? 60 : 30),
        receiveTimeout: Duration(seconds: path == ApiConstants.chat ? 60 : 30),
        followRedirects: false,
      ),
    );
    return response.data;
  }
}
