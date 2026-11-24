import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.source);
  final AuthRemoteDatasource source;
  AuthUser? _map(User? user) => user == null
      ? null
      : AuthUser(id: user.uid, email: user.email, name: user.displayName);
  @override
  AuthUser? get currentUser => _map(source.auth.currentUser);
  @override
  Stream<AuthUser?> get authChanges => source.auth.authStateChanges().map(_map);
  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code);
    } on GoogleSignInException catch (e) {
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'cancelled'
            : 'google-error',
      );
    } catch (_) {
      throw const AuthFailure('unknown');
    }
  }

  AuthUser _user(UserCredential credential) =>
      _map(credential.user) ?? (throw const AuthFailure('unknown'));
  @override
  Future<AuthUser> signIn(String email, String password) =>
      _guard(() async => _user(await source.signIn(email, password)));
  @override
  Future<AuthUser> register(String name, String email, String password) =>
      _guard(() async => _user(await source.register(name, email, password)));
  @override
  Future<AuthUser> signInWithGoogle() =>
      _guard(() async => _user(await source.signInWithGoogle()));
  @override
  Future<void> resetPassword(String email) =>
      _guard(() => source.resetPassword(email));
  @override
  Future<void> signOut() => _guard(source.signOut);
}
