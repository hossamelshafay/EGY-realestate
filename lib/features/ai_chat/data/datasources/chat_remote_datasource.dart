import 'package:egy/core/constants/api_constants.dart';
import 'package:egy/core/network/api_client.dart';
import 'package:egy/core/network/api_result.dart';
import 'package:egy/features/properties/data/models/property_listing_model.dart';
import '../../domain/entities/chat_reply.dart';

/// Parses chat replies without inventing absent catalog facts.
class ChatRemoteDatasource {
  ChatRemoteDatasource(this.client);
  final ApiClient client;

  Future<ChatReply> send(String message, String? sessionId) async {
    final body = ApiJson.object(
      await client.request(
        ApiConstants.chat,
        data: {'message': message, 'session_id': ?sessionId},
      ),
    );
    return ChatReply(
      reply: ApiJson.string(body['reply']),
      sessionId: ApiJson.string(body['session_id']),
      properties: ApiJson.list(body['properties'])
          .map((item) => PropertyListingModel.decode(item, allowMissing: true))
          .toList(),
      suggestions: ApiJson.list(
        body['suggestions'],
      ).map(ApiJson.string).toList(),
      totalMatches: body['total_matches'] == null
          ? null
          : ApiJson.integer(body['total_matches']),
    );
  }
}
