/// Stable identifiers stored in Auth; no avatar image server is needed.
abstract final class AvatarCatalog {
  static const ids = ['atlas', 'nile', 'cairo', 'lotus', 'noura', 'yasmin'];
  static bool valid(String? value) => ids.contains(value);
  static String photoUrl(String id) => 'https://avatars.egy.local/$id';
  static String? fromPhotoUrl(String? value) {
    final uri = Uri.tryParse(value ?? '');
    return uri?.host == 'avatars.egy.local' &&
            valid(uri?.pathSegments.lastOrNull)
        ? uri!.pathSegments.last
        : null;
  }
}
