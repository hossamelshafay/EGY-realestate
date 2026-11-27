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

  static const _debugLogs = bool.fromEnvironment('API_DEBUG_LOGS');
  bool _loggedBaseUrl = false;

  @visibleForTesting
  static bool allowsAndroidReverse(
    Uri uri, {
    bool isRelease = kReleaseMode,
  }) => allowsLocalLoopback(
    uri,
    isRelease: isRelease,
    isWeb: false,
    platform: TargetPlatform.android,
  );

  @visibleForTesting
  static bool allowsLocalLoopback(
    Uri uri, {
    bool isRelease = kReleaseMode,
    bool isWeb = kIsWeb,
    TargetPlatform? platform,
  }) {
    if (isRelease) return false;
    final effectivePlatform = platform ?? defaultTargetPlatform;
    final isAndroid = !isWeb && effectivePlatform == TargetPlatform.android;
    final isIos = !isWeb && effectivePlatform == TargetPlatform.iOS;
    if (!isWeb && !isAndroid && !isIos) return false;
    if (uri.scheme != 'http' ||
        !uri.hasPort ||
        uri.port <= 0 ||
        uri.port > 65535) {
      return false;
    }
    if (isWeb || isIos) {
      return uri.host == '127.0.0.1' || uri.host == 'localhost';
    }
    return uri.host == '127.0.0.1';
  }

  /// Sends JSON only to the explicitly configured backend, without redirects.
  Future<Object?> request(String path, {Map<String, Object?>? data}) async {
    final method = data == null ? 'GET' : 'POST';
    final uri = Uri.tryParse(baseUrl);
    if (!kReleaseMode && (_debugLogs || kProfileMode) && !_loggedBaseUrl) {
      _loggedBaseUrl = true;
      debugPrint(
        '[EGY API] mode=${kDebugMode ? 'debug' : 'profile'} web=$kIsWeb effective baseUrl=${baseUrl.isEmpty ? '<empty>' : baseUrl}',
      );
    }
    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      _log(method, path, 'configuration rejected (invalid baseUrl)');
      throw const ServerFailure('configuration');
    }
    if (['localhost', '127.0.0.1', '::1'].contains(uri.host) &&
        !allowsLocalLoopback(uri)) {
      _log(method, path, 'configuration rejected (loopback blocked)');
      throw const ServerFailure('configuration');
    }
    if (kReleaseMode && uri.scheme != 'https') {
      _log(method, path, 'configuration rejected (https required in release)');
      throw const ServerFailure('configuration');
    }
    final token = await idToken();
    if (token == null || token.isEmpty) {
      _log(method, path, 'no Firebase session');
      throw const UnauthenticatedFailure();
    }
    final timeout = Duration(seconds: path == ApiConstants.chat ? 60 : 30);
    try {
      final response = await _dio.request<Object?>(
        '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path',
        data: data,
        options: Options(
          method: method,
          headers: {'Authorization': 'Bearer $token'},
          contentType: Headers.jsonContentType,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          followRedirects: false,
        ),
      );
      _log(method, path, 'HTTP ${response.statusCode}');
      return response.data;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final detail = status == null && error.error != null
          ? ' (${error.error.runtimeType}: ${error.error})'
          : '';
      _log(
        method,
        path,
        status == null ? '${error.type.name}$detail' : 'HTTP $status',
      );
      rethrow;
    }
  }

  static void _log(String method, String path, String result) {
    if (kReleaseMode || (!kProfileMode && !_debugLogs)) return;
    final route = path
        .split('?')
        .first
        .replaceAll(RegExp(r'/\d+(?=/|$)'), '/:id');
    debugPrint('[EGY API] $method $route $result');
  }
}
