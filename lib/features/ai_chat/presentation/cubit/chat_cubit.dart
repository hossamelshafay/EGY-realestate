import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';
export 'chat_state.dart';

/// Session IDs live only for this screen; duplicate submissions are rejected.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.repository) : super(ChatReady(const []));
  final ChatRepository repository;
  String? _sessionId;
  String? _pending;
  int _revision = 0;

  Future<void> send(String message) async {
    final current = state as ChatReady;
    final text = message.trim();
    if (current.sending || text.isEmpty || text.length > 4000) {
      return;
    }
    final revision = ++_revision;
    _pending = text;
    emit(ChatReady(current.messages, sending: true));
    try {
      final reply = await repository.send(text, sessionId: _sessionId);
      if (!isClosed && revision == _revision) {
        _sessionId = reply.sessionId;
        _pending = null;
        emit(
          ChatReady([
            ...current.messages,
            ChatMessage(text),
            ChatMessage(reply.reply, response: reply),
          ]),
        );
      }
    } on Failure catch (failure) {
      if (!isClosed && revision == _revision) {
        if (failure is UnauthenticatedFailure) {
          _sessionId = null;
        }
        emit(ChatReady(current.messages, failure: failure));
      }
    }
  }

  Future<void> retry() async {
    if (_pending != null) {
      await send(_pending!);
    }
  }

  void reset() {
    _revision++;
    _sessionId = _pending = null;
    emit(ChatReady(const []));
  }
}
