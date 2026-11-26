import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/account_profile.dart';
import '../../domain/entities/avatar_catalog.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this.source);
  final AccountDatasource source;
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    } on GoogleSignInException {
      throw const AuthFailure('reauthentication-failed');
    } on FirebaseException catch (error) {
      throw CacheFailure(error.code);
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<AccountProfile> load() => _guard(source.load);
  @override
  Future<AccountProfile> save(String name, String avatarId) => _guard(() {
    final trimmed = name.trim();
    if (trimmed.length < 2 ||
        trimmed.length > 60 ||
        !AvatarCatalog.valid(avatarId)) {
      throw const AuthFailure('invalid-profile');
    }
    return source.save(trimmed, avatarId);
  });
  @override
  Future<void> sendVerification() => _guard(source.verify);
  @override
  Future<void> changeEmail(String email, String password) =>
      _guard(() => source.changeEmail(email.trim(), password));
  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _guard(() => source.changePassword(currentPassword, newPassword));
  @override
  Future<void> deleteAccount(String password) =>
      _guard(() => source.deleteAccount(password));
}
