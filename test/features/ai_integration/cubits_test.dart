import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/recommendations/domain/entities/recommendation_search.dart';
import 'package:egy/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:egy/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:egy/features/ai_chat/domain/entities/chat_reply.dart';
import 'package:egy/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';

PropertyListing listing(int id) => PropertyListing(
  id: id,
  title: 'Apartment',
  category: 'buy',
  propertyType: 'Apartment',
  location: 'New Cairo',
  price: 1000000,
);

class CatalogFake implements RecommendationRepository {
  final calls = <RecommendationQuery>[];
  final pending = <Completer<RecommendationSearch>>[];
  Failure? error;
  @override
  Future<RecommendationSearch> search(RecommendationQuery query) async {
    calls.add(query);
    if (error != null) {
      throw error!;
    }
    if (pending.isNotEmpty) {
      return pending.removeAt(0).future;
    }
    return RecommendationSearch(
      total: 2,
      limit: query.limit,
      offset: query.offset,
      items: [listing(query.offset + 1)],
    );
  }

  @override
  Future<List<PropertyListing>> similar(
    int propertyId, {
    int limit = 6,
  }) async => [listing(propertyId + 1)];
}

class ChatFake implements ChatRepository {
  final sessions = <String?>[];
  Completer<ChatReply>? pending;
  Failure? error;
  @override
  Future<ChatReply> send(String message, {String? sessionId}) async {
    sessions.add(sessionId);
    if (error != null) {
      throw error!;
    }
    if (pending != null) {
      return pending!.future;
    }
    return ChatReply(
      reply: 'A real catalog result',
      sessionId: 'session',
      properties: [listing(1)],
      suggestions: ['More'],
    );
  }
}

void main() {
  test(
    'recommendations retain filters on pagination and recover failed pages',
    () async {
      final repo = CatalogFake(), cubit = RecommendationsCubit(CatalogFake());
      await cubit.close();
      final subject = RecommendationsCubit(repo);
      addTearDown(subject.close);
      await subject.search(
        const RecommendationQuery(category: 'buy', minPrice: 500),
      );
      repo.error = const NetworkFailure();
      await subject.more();
      expect((subject.state as RecommendationsReady).items.single.id, 1);
      expect(
        (subject.state as RecommendationsReady).failure,
        isA<NetworkFailure>(),
      );
      repo.error = null;
      await subject.more();
      expect((subject.state as RecommendationsReady).items.map((p) => p.id), [
        1,
        2,
      ]);
      expect(repo.calls.last.category, 'buy');
      expect(repo.calls.last.minPrice, 500);
      expect(repo.calls.last.offset, 1);
    },
  );
  test(
    'latest filter request wins and similar results exclude pagination',
    () async {
      final first = Completer<RecommendationSearch>(),
          second = Completer<RecommendationSearch>();
      final repo = CatalogFake()..pending.addAll([first, second]);
      final subject = RecommendationsCubit(repo);
      addTearDown(subject.close);
      final old = subject.search(const RecommendationQuery(category: 'buy'));
      final latest = subject.search(
        const RecommendationQuery(category: 'rent'),
      );
      second.complete(
        RecommendationSearch(
          total: 1,
          limit: 6,
          offset: 0,
          items: [listing(2)],
        ),
      );
      await latest;
      first.complete(
        RecommendationSearch(
          total: 1,
          limit: 6,
          offset: 0,
          items: [listing(1)],
        ),
      );
      await old;
      expect((subject.state as RecommendationsReady).items.single.id, 2);
      await subject.similar(20);
      expect((subject.state as RecommendationsReady).items.single.id, 21);
      final before = repo.calls.length;
      await subject.more();
      expect(repo.calls.length, before);
    },
  );
  test(
    'chat reuses session, prevents duplicate sends and clears state on reset',
    () async {
      final repo = ChatFake(), subject = ChatCubit(ChatFake());
      await subject.close();
      final chat = ChatCubit(repo);
      addTearDown(chat.close);
      await chat.send('hello');
      await chat.send('more');
      expect(repo.sessions, [null, 'session']);
      expect((chat.state as ChatReady).messages, hasLength(4));
      repo.pending = Completer<ChatReply>();
      final sending = chat.send('pending');
      await chat.send('duplicate');
      expect(repo.sessions, hasLength(3));
      chat.reset();
      repo.pending!.complete(
        ChatReply(
          reply: 'late',
          sessionId: 'old',
          properties: [],
          suggestions: [],
        ),
      );
      await sending;
      expect((chat.state as ChatReady).messages, isEmpty);
      repo.pending = null;
      await chat.send('new');
      expect(repo.sessions.last, isNull);
    },
  );
  test(
    'failed chat preserves draft for explicit retry without invented response',
    () async {
      final repo = ChatFake()..error = const NetworkFailure();
      final chat = ChatCubit(repo);
      addTearDown(chat.close);
      await chat.send('hello');
      expect((chat.state as ChatReady).messages, isEmpty);
      expect((chat.state as ChatReady).failure, isA<NetworkFailure>());
      repo.error = null;
      await chat.retry();
      expect((chat.state as ChatReady).messages, hasLength(2));
    },
  );
}
