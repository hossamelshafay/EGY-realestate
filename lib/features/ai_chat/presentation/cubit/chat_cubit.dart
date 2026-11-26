import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import '../../domain/repositories/chat_history_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_history_codec.dart';
import 'chat_state.dart';
export 'chat_state.dart';

/// Keeps one user-scoped conversation and rejects duplicate submissions.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.repository, {this.history, this.session})
    : super(ChatReady(const [])) {
    if (session != null) {
      _subscription = session!.stream.listen(
        (state) => _switchUser(state.user?.id),
      );
      _switchUser(session!.state.user?.id);
    }
  }
  final ChatRepository repository;
  final ChatHistoryRepository? history;
  final SessionCubit? session;
  StreamSubscription<SessionState>? _subscription;
  final Map<String, Future<void>> _writes = {};
  String? _uid;
  int _sequence = 0;
  String? _sessionId;
  String? _pending;
  int _revision = 0;

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  Future<void> _switchUser(String? uid) async {
    if (uid == _uid) return;
    final revision = ++_revision;
    _uid = uid;
    _sessionId = _pending = null;
    emit(ChatReady(const [], loading: uid != null));
    if (uid == null || history == null) return;
    try {
      final queued = _writes[uid];
      if (queued != null) await queued.catchError((Object _) {});
      final raw = await history!.read(uid);
      if (isClosed || revision != _revision) return;
      if (raw == null) {
        emit(ChatReady(const []));
      } else {
        final (messages, sessionId, pending) = ChatHistoryCodec.decode(raw);
        _sessionId = sessionId;
        _pending = pending;
        emit(
          ChatReady(
            messages,
            failure: pending == null ? null : const NetworkFailure(),
          ),
        );
      }
    } catch (_) {
      if (!isClosed && revision == _revision) {
        emit(
          ChatReady(
            const [],
            failure: const CacheFailure('chat_history'),
            loading: true,
          ),
        );
      }
    }
  }

  Future<bool> _save(List<ChatMessage> messages) async {
    final uid = _uid;
    if (uid == null || history == null) return true;
    final data = ChatHistoryCodec.encode(messages, _sessionId, _pending);
    final previous = _writes[uid] ?? Future<void>.value();
    final write = previous
        .catchError((Object _) {})
        .then((_) => history!.write(uid, data));
    _writes[uid] = write;
    try {
      await write;
      return true;
    } catch (_) {
      if (!isClosed && uid == _uid) {
        final current = state as ChatReady;
        emit(
          ChatReady(
            current.messages,
            sending: current.sending,
            failure: const CacheFailure('chat_history'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> send(String message) async {
    final current = state as ChatReady;
    final text = message.trim();
    if (current.loading ||
        current.sending ||
        text.isEmpty ||
        text.length > 4000 ||
        (session != null && _uid == null)) {
      return;
    }
    await _deliver(text, [
      ...current.messages,
      ChatMessage(text, id: _newId()),
    ]);
  }

  Future<void> _deliver(String text, List<ChatMessage> messages) async {
    final revision = ++_revision;
    _pending = text;
    emit(ChatReady(messages, sending: true));
    await _save(messages);
    if (isClosed || revision != _revision) return;
    try {
      final reply = await repository.send(text, sessionId: _sessionId);
      if (!isClosed && revision == _revision) {
        _sessionId = reply.sessionId;
        _pending = null;
        final updated = [
          ...messages,
          ChatMessage(reply.reply, response: reply, id: _newId()),
        ];
        emit(ChatReady(updated));
        await _save(updated);
      }
    } on Failure catch (failure) {
      if (!isClosed && revision == _revision) {
        if (failure is UnauthenticatedFailure) {
          _sessionId = null;
        }
        final updated = [
          ...messages.take(messages.length - 1),
          ChatMessage(text, id: messages.last.id, failed: true),
        ];
        emit(ChatReady(updated, failure: failure));
        await _save(updated);
      }
    }
  }

  Future<void> retry() async {
    final current = state as ChatReady;
    if (current.failure is CacheFailure) {
      if (current.loading) {
        final uid = _uid;
        _uid = null;
        await _switchUser(uid);
      } else {
        final revision = _revision;
        final saved = await _save(current.messages);
        if (saved &&
            !isClosed &&
            revision == _revision &&
            (state as ChatReady).failure is CacheFailure) {
          emit(ChatReady(current.messages, sending: current.sending));
        }
      }
      return;
    }
    if (_pending != null && !current.sending) {
      if (current.messages.isEmpty) return;
      final messages = [...current.messages];
      final last = messages.removeLast();
      messages.add(ChatMessage(last.text, id: last.id));
      await _deliver(_pending!, messages);
    }
  }

  void reset() {
    _revision++;
    _sessionId = _pending = null;
    emit(ChatReady(const []));
    unawaited(_save(const []).then((_) {}));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    for (final write in _writes.values) {
      try {
        await write;
      } catch (_) {}
    }
    await super.close();
  }
}
