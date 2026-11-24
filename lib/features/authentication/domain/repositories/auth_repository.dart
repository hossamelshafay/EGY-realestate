import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authChanges;
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> register(String name, String email, String password);
  Future<AuthUser> signInWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}
