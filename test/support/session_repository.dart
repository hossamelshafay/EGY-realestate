import 'dart:async';

import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';

class SessionTestRepository implements AuthRepository {
  SessionTestRepository({this._user});
  AuthUser? _user;
  final changes = StreamController<AuthUser?>.broadcast(sync: true);
  Completer<void>? authenticationGate;
  bool failLogout = false;
  int remainingFailures = 0;
  int attempts = 0;
  @override
  AuthUser? get currentUser => _user;
  @override
  Stream<AuthUser?> get authChanges => changes.stream;
  void restore(AuthUser? user) {
    _user = user;
    changes.add(user);
  }

  Future<AuthUser> _authenticate(String name) async {
    attempts++;
    if (remainingFailures > 0) {
      remainingFailures--;
      throw const AuthFailure('invalid-credential');
    }
    restore(const AuthUser(id: 'test-user', email: 'nour@example.com'));
    await authenticationGate?.future;
    _user = AuthUser(id: 'test-user', email: 'nour@example.com', name: name);
    return _user!;
  }

  @override
  Future<AuthUser> signIn(String email, String password) =>
      _authenticate('Nour');
  @override
  Future<AuthUser> register(String name, String email, String password) =>
      _authenticate(name);
  @override
  Future<AuthUser> signInWithGoogle() => _authenticate('Nour');
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signOut() async {
    if (failLogout) throw StateError('signout failed');
    restore(null);
  }

  Future<void> dispose() => changes.close();
}
