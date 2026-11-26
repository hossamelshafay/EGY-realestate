import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this.auth, this.google);
  final FirebaseAuth auth;
  final GoogleSignIn google;
  Future<void>? _googleInitialization;
  Future<void> initializeGoogle() async {
    try { await (_googleInitialization ??= google.initialize()); }
    catch (_) { _googleInitialization = null; rethrow; }
  }
  Future<UserCredential> signIn(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);
  Future<User?> register(
    String name,
    String email,
    String password, {
    String? avatarId,
  }) async {
    if (!AvatarCatalog.valid(avatarId)) {
      throw FirebaseAuthException(code: 'avatar-required');
    }
    final existing = auth.currentUser;
    User? user;
    if (existing != null &&
        existing.email?.toLowerCase() == email.toLowerCase()) {
      user = existing;
    } else {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;
    }
    try {
      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(AvatarCatalog.photoUrl(avatarId!));
    } catch (_) {
      throw FirebaseAuthException(code: 'profile-save-partial');
    }
    return user;
  }

  Future<UserCredential> signInWithGoogle({String? avatarId}) async {
    if (avatarId != null && !AvatarCatalog.valid(avatarId)) {
      throw FirebaseAuthException(code: 'avatar-required');
    }
    try {
      await initializeGoogle();
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }
    final account = await google.authenticate();
    final token = account.authentication.idToken;
    if (token == null) {
      throw FirebaseAuthException(code: 'missing-google-token');
    }
    final result = await auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
    if (avatarId != null) {
      await result.user?.updatePhotoURL(AvatarCatalog.photoUrl(avatarId));
    }
    return result;
  }

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email);
  Future<User?> reloadUser() async {
    final current = auth.currentUser;
    if (current == null) return null;
    await current.reload();
    return auth.currentUser;
  }

  Future<void> signOut() async {
    await auth.signOut();
    if (_googleInitialization != null) await google.signOut();
  }
}
