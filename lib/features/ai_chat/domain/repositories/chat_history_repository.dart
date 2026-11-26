/// Stores the serialized active conversation for an authenticated account.
abstract interface class ChatHistoryRepository {
  Future<String?> read(String uid);
  Future<void> write(String uid, String value);
}
