import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authChanges;
  Future<AuthUser?> refreshUser();
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> register(
    String name,
    String email,
    String password, {
    String? avatarId,
  });
  Future<AuthUser> signInWithGoogle({String? avatarId});
  Future<void> resetPassword(String email);
  Future<void> signOut();
}
