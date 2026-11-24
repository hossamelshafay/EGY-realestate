import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
