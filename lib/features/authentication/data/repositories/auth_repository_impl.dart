import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
import 'package:egy/features/profile/data/datasources/avatar_preferences.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.source, {this.avatars});
  final AuthRemoteDatasource source;
  final AvatarPreferences? avatars;
  AuthUser? _map(User? user) => user == null
      ? null
      : AuthUser(
          id: user.uid,
          email: user.email,
          name: user.displayName,
          emailVerified: user.emailVerified,
          photoUrl: user.photoURL,
          avatarId: AvatarCatalog.fromPhotoUrl(user.photoURL) ?? avatars?.read(user.uid),
        );
  @override
  AuthUser? get currentUser => _map(source.auth.currentUser);
  @override
  Stream<AuthUser?> get authChanges => source.auth.userChanges().map(_map);
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

  AuthUser _user(User? user) =>
      _map(user) ?? (throw const AuthFailure('unknown'));
  Future<AuthUser> _remember(User? user, String? avatarId) async {
    final uid = user?.uid;
    if (uid != null && avatarId != null) await avatars?.write(uid, avatarId);
    return _user(user);
  }
  @override
  Future<AuthUser> signIn(String email, String password) =>
      _guard(() async => _user((await source.signIn(email, password)).user));
  @override
  Future<AuthUser> register(
    String name,
    String email,
    String password, {
    String? avatarId,
  }) => _guard(
    () async =>
        _remember(await source.register(name, email, password, avatarId: avatarId), avatarId),
  );
  @override
  Future<AuthUser> signInWithGoogle({String? avatarId}) => _guard(
    () async => _remember((await source.signInWithGoogle(avatarId: avatarId)).user, avatarId),
  );
  @override
  Future<void> resetPassword(String email) =>
      _guard(() => source.resetPassword(email));
  @override
  Future<AuthUser?> refreshUser() => _guard(() async {
    final user = await source.reloadUser();
    return _map(user);
  });
  @override
  Future<void> signOut() => _guard(source.signOut);
}
