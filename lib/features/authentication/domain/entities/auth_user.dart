class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.avatarId,
    this.photoUrl,
    this.emailVerified = false,
  });
  final String id;
  final String? email;
  final String? name;
  final String? avatarId, photoUrl;
  final bool emailVerified;
}
