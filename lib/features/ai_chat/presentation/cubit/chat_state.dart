import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/chat_reply.dart';

/// A local user message or the corresponding grounded assistant reply.
class ChatMessage {
  const ChatMessage(this.text, {this.response});
  final String text;
  final ChatReply? response;
  bool get isUser => response == null;
}

sealed class ChatState {
  const ChatState();
}

final class ChatReady extends ChatState {
  ChatReady(List<ChatMessage> messages, {this.sending = false, this.failure})
    : messages = List.unmodifiable(messages);
  final List<ChatMessage> messages;
  final bool sending;
  final Failure? failure;
}
