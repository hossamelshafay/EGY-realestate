import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/network/api_client.dart';
import 'package:egy/features/ai_chat/data/datasources/chat_remote_datasource.dart';
import 'package:egy/features/ai_chat/data/repositories/chat_repository_impl.dart';
import 'package:egy/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:egy/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:egy/features/recommendations/domain/entities/recommendation_search.dart';

class RecordingClient extends ApiClient {
  RecordingClient() : super(baseUrl: '', idToken: () async => null);
  Object? response;
  Object? error;
  String? path;
  Map<String, Object?>? data;
  int calls = 0;

  @override
  Future<Object?> request(String path, {Map<String, Object?>? data}) async {
    calls++;
    this.path = path;
    this.data = data;
    if (error case final Object error) throw error;
    return response;
  }
}

Map<String, Object?> listing(int id) => {
  'id': id,
  'title': 'Apartment',
  'category': 'buy',
  'property_type': 'Apartment',
  'location': 'New Cairo',
  'price': 1000000,
  'size': 130,
  'bedrooms': 3,
  'bathrooms': 2,
};

void main() {
  late RecordingClient client;
  late RecommendationRepositoryImpl recommendations;
  setUp(() {
    client = RecordingClient();
    recommendations = RecommendationRepositoryImpl(
      RecommendationRemoteDatasource(client),
    );
  });

  test('search sends explicit filters and preserves an empty result', () async {
    client.response = {
      'status': 'success',
      'total': 0,
      'limit': 6,
      'offset': 0,
      'items': <Object?>[],
    };
    final page = await recommendations.search(
      const RecommendationQuery(category: 'buy', minPrice: 2000000),
    );
    expect(client.path, '/api/recommendations/search');
    expect(client.data?['min_price'], 2000000);
    expect(client.data?['category'], 'buy');
    expect(page.total, 0);
    expect(page.items, isEmpty);
    expect(() => page.items.clear(), throwsUnsupportedError);
  });

  test('invalid filters are rejected before HTTP', () async {
    for (final query in [
      const RecommendationQuery(limit: 0),
      const RecommendationQuery(offset: -1),
      const RecommendationQuery(minPrice: 20, maxPrice: 10),
      const RecommendationQuery(maxPrice: double.infinity),
    ]) {
      await expectLater(
        recommendations.search(query),
        throwsA(isA<ServerFailure>()),
      );
    }
    expect(client.calls, 0);
  });

  test(
    'neighbors decode catalog facts and reject self or duplicate IDs',
    () async {
      client.response = {
        'status': 'success',
        'property_id': 10,
        'items': [listing(11)],
      };
      final items = await recommendations.similar(10, limit: 2);
      expect(client.path, '/api/recommendations/similar/10?top_n=2');
      expect(items.single.price, 1000000);
      for (final invalid in [
        [listing(10)],
        [listing(11), listing(11)],
      ]) {
        client.response = {
          'status': 'success',
          'property_id': 10,
          'items': invalid,
        };
        await expectLater(
          recommendations.similar(10),
          throwsA(isA<ServerFailure>()),
        );
      }
    },
  );

  test('malformed pagination and missing listing fields fail closed', () async {
    for (final body in [
      {
        'status': 'success',
        'total': 1,
        'limit': 99,
        'offset': 0,
        'items': [listing(11)],
      },
      {
        'status': 'success',
        'total': 1,
        'limit': 6,
        'offset': 0,
        'items': [
          {'id': 11},
        ],
      },
    ]) {
      client.response = body;
      await expectLater(
        recommendations.search(const RecommendationQuery()),
        throwsA(isA<ServerFailure>()),
      );
    }
  });

  test(
    'HTTP auth, service outage and connection errors map to failures',
    () async {
      for (final status in [401, 403, 503]) {
        final options = RequestOptions(path: '/api/recommendations/search');
        client.error = DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            statusCode: status,
          ),
        );
        await expectLater(
          recommendations.search(const RecommendationQuery()),
          throwsA(
            status == 503
                ? isA<ServerFailure>()
                : isA<UnauthenticatedFailure>(),
          ),
        );
      }
      client.error = DioException(requestOptions: RequestOptions(path: '/'));
      await expectLater(
        recommendations.search(const RecommendationQuery()),
        throwsA(isA<NetworkFailure>()),
      );
    },
  );

  test('default chat gate makes no HTTP request', () async {
    final chat = ChatRepositoryImpl(ChatRemoteDatasource(client));
    await expectLater(chat.send('hello'), throwsA(isA<ServerFailure>()));
    expect(client.calls, 0);
  });

  test(
    'scripted chat transport preserves session and nullable catalog facts',
    () async {
      final chat = ChatRepositoryImpl(
        ChatRemoteDatasource(client),
        enabled: true,
      );
      client.response = {
        'reply': 'Found a listing',
        'session_id': 'session-1',
        'properties': [listing(11)..['price'] = null],
        'suggestions': ['Show more'],
        'total_matches': 1,
      };
      final reply = await chat.send(' hello ', sessionId: 'session-1');
      expect(client.path, '/api/chat');
      expect(client.data, {'message': 'hello', 'session_id': 'session-1'});
      expect(reply.properties.single.price, isNull);
      expect(reply.sessionId, 'session-1');
      client.response = {'reply': '', 'session_id': 'session-1'};
      await expectLater(chat.send('hello'), throwsA(isA<ServerFailure>()));
    },
  );

  test('blank and oversized chat input never reaches HTTP', () async {
    final chat = ChatRepositoryImpl(
      ChatRemoteDatasource(client),
      enabled: true,
    );
    for (final text in [' ', List.filled(4001, 'a').join()]) {
      await expectLater(chat.send(text), throwsA(isA<ServerFailure>()));
    }
    expect(client.calls, 0);
  });
}
