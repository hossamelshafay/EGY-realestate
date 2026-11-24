import '../entities/chat_reply.dart';

/// Chat transport contract; live access remains disabled pending approval.
abstract interface class ChatRepository {
  Future<ChatReply> send(String message, {String? sessionId});
}
