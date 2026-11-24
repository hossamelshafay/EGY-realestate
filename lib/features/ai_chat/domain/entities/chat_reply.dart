import 'package:egy/features/properties/domain/entities/property_listing.dart';

/// A grounded response; callers keep session IDs in memory.
class ChatReply {
  ChatReply({
    required this.reply,
    required this.sessionId,
    required List<PropertyListing> properties,
    required List<String> suggestions,
    this.totalMatches,
  }) : properties = List.unmodifiable(properties),
       suggestions = List.unmodifiable(suggestions);

  final String reply, sessionId;
  final List<PropertyListing> properties;
  final List<String> suggestions;
  final int? totalMatches;
}
