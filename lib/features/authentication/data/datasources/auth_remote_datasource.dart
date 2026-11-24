import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this.auth, this.google);
  final FirebaseAuth auth;
  final GoogleSignIn google;
  Future<void>? _googleInitialization;
  Future<UserCredential> signIn(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> register(
    String name,
    String email,
    String password,
  ) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user?.updateDisplayName(name);
    return result;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await (_googleInitialization ??= google.initialize());
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }
    final account = await google.authenticate();
    final token = account.authentication.idToken;
    if (token == null) {
      throw FirebaseAuthException(code: 'missing-google-token');
    }
    return auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
  }

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email);
  Future<void> signOut() async {
    await auth.signOut();
    if (_googleInitialization != null) await google.signOut();
  }
}
