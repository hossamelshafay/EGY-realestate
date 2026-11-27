import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/core/constants/api_constants.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/network/api_client.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('Android debug sends catalog requests through ADB reverse', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final adapter = RecordingAdapter();
    final client = ApiClient(
      baseUrl: 'http://127.0.0.1:8000',
      dio: Dio()..httpClientAdapter = adapter,
      idToken: () async => 'test-token',
    );

    const payload = {'category': 'buy', 'limit': 5, 'exclude_ids': <int>[]};
    await client.request(ApiConstants.catalogSample, data: payload);
    await client.request('${ApiConstants.recommendationsById}/17');

    final request = adapter.requests.first;
    expect(request.uri.host, '127.0.0.1');
    expect(request.uri.port, 8000);
    expect(request.uri.path, ApiConstants.catalogSample);
    expect(request.method, 'POST');
    expect(request.data, payload);
    expect(request.headers['Authorization'], 'Bearer test-token');
    expect(adapter.requests.last.method, 'GET');
  });

  test(
    'Android reverse still requires an explicit port and a Firebase token',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final adapter = RecordingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      for (final url in [
        'http://127.0.0.1',
        'http://127.0.0.1:0',
        'http://127.0.0.1:65536',
        'http://localhost:8000',
        'http://[::1]:8000',
        'https://127.0.0.1:8000',
      ]) {
        final client = ApiClient(
          baseUrl: url,
          dio: dio,
          idToken: () async => 'test-token',
        );
        await expectLater(
          client.request(ApiConstants.catalogSample, data: {}),
          throwsA(const ServerFailure('configuration')),
        );
      }
      final signedOut = ApiClient(
        baseUrl: 'http://127.0.0.1:8000',
        dio: dio,
        idToken: () async => null,
      );
      await expectLater(
        signedOut.request(ApiConstants.catalogSample, data: {}),
        throwsA(isA<UnauthenticatedFailure>()),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'refreshes tokens and applies model timeouts without redirects',
    () async {
      final adapter = RecordingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      var token = 0;
      final client = ApiClient(
        baseUrl: 'https://backend.example',
        dio: dio,
        idToken: () async => 'test-${++token}',
      );
      await client.request('/api/predict', data: {'size': 130});
      await client.request('/api/chat', data: {'message': 'hello'});
      expect(adapter.requests[0].headers['Authorization'], 'Bearer test-1');
      expect(adapter.requests[1].headers['Authorization'], 'Bearer test-2');
      expect(adapter.requests[0].receiveTimeout, const Duration(seconds: 30));
      expect(adapter.requests[1].receiveTimeout, const Duration(seconds: 60));
      expect(
        adapter.requests.every((request) => !request.followRedirects),
        isTrue,
      );
    },
  );

  test('rejects invalid hosts and missing auth before transport', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final adapter = RecordingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    for (final url in [
      '',
      'http://localhost:8000',
      'http://127.0.0.1:8000',
      'https://user:pass@example.com',
      'https://example.com?key=secret',
    ]) {
      final client = ApiClient(
        baseUrl: url,
        dio: dio,
        idToken: () async => 'test',
      );
      await expectLater(
        client.request('/api/predict'),
        throwsA(isA<ServerFailure>()),
      );
    }
    final client = ApiClient(
      baseUrl: 'https://backend.example',
      dio: dio,
      idToken: () async => null,
    );
    await expectLater(
      client.request('/api/predict'),
      throwsA(isA<UnauthenticatedFailure>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test('allowsAndroidReverse permits non-release Android 127.0.0.1:port and blocks release', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final uri = Uri.parse('http://127.0.0.1:8000');
    expect(ApiClient.allowsAndroidReverse(uri, isRelease: false), isTrue);
    expect(ApiClient.allowsAndroidReverse(uri, isRelease: true), isFalse);
  });

  test('allowsLocalLoopback permits Web 127.0.0.1/localhost in non-release and blocks release', () {
    expect(
      ApiClient.allowsLocalLoopback(
        Uri.parse('http://127.0.0.1:8000'),
        isRelease: false,
        isWeb: true,
      ),
      isTrue,
    );
    expect(
      ApiClient.allowsLocalLoopback(
        Uri.parse('http://localhost:8000'),
        isRelease: false,
        isWeb: true,
      ),
      isTrue,
    );
    expect(
      ApiClient.allowsLocalLoopback(
        Uri.parse('http://127.0.0.1:8000'),
        isRelease: true,
        isWeb: true,
      ),
      isFalse,
    );
  });

  test('allowsLocalLoopback permits iOS Simulator 127.0.0.1/localhost in non-release and blocks release', () {
    expect(
      ApiClient.allowsLocalLoopback(
        Uri.parse('http://127.0.0.1:8000'),
        isRelease: false,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      ApiClient.allowsLocalLoopback(
        Uri.parse('http://localhost:8000'),
        isRelease: false,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      ApiClient.allowsLocalLoopback(
        Uri.parse('http://127.0.0.1:8000'),
        isRelease: true,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
  });
}
