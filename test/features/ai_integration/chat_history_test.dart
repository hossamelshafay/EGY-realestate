import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:egy/features/ai_chat/data/repositories/secure_chat_history_repository.dart';
import 'package:egy/features/ai_chat/domain/entities/chat_reply.dart';
import 'package:egy/features/ai_chat/domain/repositories/chat_history_repository.dart';
import 'package:egy/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';

import '../../support/session_repository.dart';

class MemoryHistory implements ChatHistoryRepository {
  final values = <String, String>{};
  @override
  Future<String?> read(String uid) async => values[uid];
  @override
  Future<void> write(String uid, String value) async => values[uid] = value;
}

class DelayedHistory extends MemoryHistory {
  final firstWrite = Completer<void>();
  var writes = 0;
  @override
  Future<void> write(String uid, String value) async {
    if (writes++ == 0) await firstWrite.future;
    await super.write(uid, value);
  }
}

class ChatTransport implements ChatRepository {
  Completer<ChatReply>? gate;
  final sessions = <String?>[];
  @override
  Future<ChatReply> send(String message, {String? sessionId}) async {
    sessions.add(sessionId);
    if (gate != null) return gate!.future;
    return ChatReply(
      reply: 'answer',
      sessionId: 'session',
      properties: [],
      suggestions: [],
    );
  }
}

void main() {
  test('queued reset wins over an earlier delayed write', () async {
    final auth = SessionTestRepository(user: const AuthUser(id: 'a'));
    final session = SessionCubit(auth);
    final storage = DelayedHistory();
    final chat = ChatCubit(ChatTransport(), history: storage, session: session);
    await Future<void>.delayed(Duration.zero);
    final sending = chat.send('old');
    await Future<void>.delayed(Duration.zero);
    chat.reset();
    storage.firstWrite.complete();
    await sending;
    await chat.close();
    final restored = ChatCubit(ChatTransport(), history: storage, session: session);
    await Future<void>.delayed(Duration.zero);
    expect((restored.state as ChatReady).messages, isEmpty);
    await restored.close();
    await session.close();
    await auth.dispose();
  });

  test('secure storage separates account keys', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final storage = SecureChatHistoryRepository(const FlutterSecureStorage());
    await storage.write('account-a', 'first');
    await storage.write('account-b', 'second');
    expect(await storage.read('account-a'), 'first');
    expect(await storage.read('account-b'), 'second');
    expect(await storage.read('account-c'), isNull);
    expect(() => storage.read(''), throwsArgumentError);
  });

  test(
    'logout and account switching isolate and restore conversations',
    () async {
      final auth = SessionTestRepository(user: const AuthUser(id: 'a'));
      final session = SessionCubit(auth);
      final storage = MemoryHistory();
      final chat = ChatCubit(
        ChatTransport(),
        history: storage,
        session: session,
      );
      await Future<void>.delayed(Duration.zero);
      await chat.send('account a');
      auth.restore(null);
      await Future<void>.delayed(Duration.zero);
      expect((chat.state as ChatReady).messages, isEmpty);
      auth.restore(const AuthUser(id: 'b'));
      await Future<void>.delayed(Duration.zero);
      expect((chat.state as ChatReady).messages, isEmpty);
      await chat.send('account b');
      auth.restore(const AuthUser(id: 'a'));
      await Future<void>.delayed(Duration.zero);
      expect((chat.state as ChatReady).messages.first.text, 'account a');
      await chat.close();
      await session.close();
      await auth.dispose();
    },
  );

  test(
    'restores per account across restart and resets against late responses',
    () async {
      final auth = SessionTestRepository(user: const AuthUser(id: 'a'));
      final session = SessionCubit(auth);
      final storage = MemoryHistory();
      final transport = ChatTransport();
      final first = ChatCubit(transport, history: storage, session: session);
      await Future<void>.delayed(Duration.zero);
      await first.send('hello');
      final ids = (first.state as ChatReady).messages.map((m) => m.id).toList();
      await first.close();

      final restored = ChatCubit(transport, history: storage, session: session);
      await Future<void>.delayed(Duration.zero);
      expect((restored.state as ChatReady).messages.map((m) => m.text), [
        'hello',
        'answer',
      ]);
      expect((restored.state as ChatReady).messages.map((m) => m.id), ids);
      transport.gate = Completer<ChatReply>();
      final pending = restored.send('late');
      await Future<void>.delayed(Duration.zero);
      restored.reset();
      transport.gate!.complete(
        ChatReply(
          reply: 'stale',
          sessionId: 'old',
          properties: [],
          suggestions: [],
        ),
      );
      await pending;
      await restored.close();

      final reopened = ChatCubit(transport, history: storage, session: session);
      await Future<void>.delayed(Duration.zero);
      expect((reopened.state as ChatReady).messages, isEmpty);
      transport.gate = null;
      await reopened.send('new');
      expect(transport.sessions.last, isNull);
      await reopened.close();
      await session.close();
      await auth.dispose();
    },
  );
}
