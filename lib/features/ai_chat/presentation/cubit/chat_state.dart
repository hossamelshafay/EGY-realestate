import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/chat_reply.dart';

/// A local user message or the corresponding grounded assistant reply.
class ChatMessage {
  const ChatMessage(
    this.text, {
    this.response,
    this.id = '',
    this.failed = false,
  });
  final String text;
  final ChatReply? response;
  final String id;
  final bool failed;
  bool get isUser => response == null;
}

sealed class ChatState {
  const ChatState();
}

final class ChatReady extends ChatState {
  ChatReady(
    List<ChatMessage> messages, {
    this.sending = false,
    this.failure,
    this.loading = false,
  }) : messages = List.unmodifiable(messages);
  final List<ChatMessage> messages;
  final bool sending;
  final bool loading;
  final Failure? failure;
}
