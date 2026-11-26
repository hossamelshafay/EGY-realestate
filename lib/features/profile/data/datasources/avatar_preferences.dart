import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/avatar_catalog.dart';

/// UID-scoped fallback if a federated provider replaces Auth's photoURL.
class AvatarPreferences {
  const AvatarPreferences(this.preferences);
  final SharedPreferences preferences;
  String _key(String uid) => 'profile_avatar_v1_$uid';
  String? read(String uid) {
    final value = preferences.getString(_key(uid));
    return AvatarCatalog.valid(value) ? value : null;
  }
  Future<void> write(String uid, String value) async {
    if (uid.isEmpty || !AvatarCatalog.valid(value)) throw ArgumentError('Invalid avatar selection');
    await preferences.setString(_key(uid), value);
  }
  Future<void> remove(String uid) async { await preferences.remove(_key(uid)); }
}
