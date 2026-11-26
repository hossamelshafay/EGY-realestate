import 'dart:convert';

import 'package:egy/features/properties/data/models/property_listing_model.dart';

import '../../domain/entities/chat_reply.dart';
import 'chat_state.dart';

/// Encodes the message order, delivery status and backend conversation handle.
abstract final class ChatHistoryCodec {
  static String encode(
    List<ChatMessage> messages,
    String? session,
    String? pending,
  ) => jsonEncode({
    'version': 1,
    'session': session,
    'pending': pending,
    'messages': messages
        .map(
          (m) => {
            'id': m.id,
            'text': m.text,
            'failed': m.failed,
            if (m.response case final r?)
              'reply': {
                'session': r.sessionId,
                'suggestions': r.suggestions,
                'total': r.totalMatches,
              'properties': r.properties.map((property) => {
                ...PropertyListingModel.encode(property),
                'city_ar': property.localizedCity,
                'description': property.description,
                'amenities': property.amenities,
                'images': property.images,
              }).toList(),
              },
          },
        )
        .toList(),
  });

  static (List<ChatMessage>, String?, String?) decode(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (data['version'] != 1) throw const FormatException('Invalid history');
    final ids = <String>{};
    final messages = (data['messages'] as List).map((entry) {
      final item = entry as Map<String, dynamic>;
      final id = item['id'] as String;
      if (id.isEmpty || !ids.add(id)) {
        throw const FormatException('Invalid message ID');
      }
      final text = item['text'] as String;
      final reply = item['reply'] as Map<String, dynamic>?;
      return ChatMessage(
        text,
        id: id,
        failed: item['failed'] as bool,
        response: reply == null
            ? null
            : ChatReply(
                reply: text,
                sessionId: reply['session'] as String,
                suggestions: (reply['suggestions'] as List).cast<String>(),
                totalMatches: reply['total'] as int?,
                properties: (reply['properties'] as List)
                    .map(
                      (p) => PropertyListingModel.decode(p, allowMissing: true),
                    )
                    .toList(),
              ),
      );
    }).toList();
    return (messages, data['session'] as String?, data['pending'] as String?);
  }
}
