import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/chat_history_repository.dart';

/// Uses platform-protected storage and a separate key for each Firebase UID.
class SecureChatHistoryRepository implements ChatHistoryRepository {
  SecureChatHistoryRepository(this.storage);
  final FlutterSecureStorage storage;

  String _key(String uid) {
    if (uid.isEmpty) throw ArgumentError.value(uid, 'uid');
    return 'chat_v1_${base64Url.encode(utf8.encode(uid))}';
  }

  @override
  Future<String?> read(String uid) => storage.read(key: _key(uid));

  @override
  Future<void> write(String uid, String value) =>
      storage.write(key: _key(uid), value: value);
}
