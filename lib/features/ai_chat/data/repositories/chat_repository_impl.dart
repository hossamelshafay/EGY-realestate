import 'package:egy/core/errors/failures.dart';
import 'package:egy/core/network/api_result.dart';
import '../../domain/entities/chat_reply.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Development builds can opt in after approval for a live provider test.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this.source, {
    this.enabled = const bool.fromEnvironment('ENABLE_LIVE_CHAT'),
  });
  final ChatRemoteDatasource source;
  final bool enabled;

  @override
  Future<ChatReply> send(String message, {String? sessionId}) => guardApi(() {
    if (!enabled) throw const ServerFailure('chat_disabled', statusCode: 503);
    final text = message.trim();
    if (text.isEmpty ||
        text.length > 4000 ||
        (sessionId != null && sessionId.trim().isEmpty)) {
      throw const ServerFailure('input', statusCode: 422);
    }
    return source.send(text, sessionId);
  });
}
