import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import '../../domain/entities/account_profile.dart';
import '../../domain/entities/avatar_catalog.dart';
import 'account_datasource.dart';
import 'account_cleanup.dart';
import 'avatar_preferences.dart';

/// Scoped Firebase operations; never updates an unverified mailbox directly.
class AccountRemoteDatasource implements AccountDatasource {
  AccountRemoteDatasource(this.auth, this.store, this.google, this.storage, {required this.initializeGoogle, required this.avatars});
  final FirebaseAuth auth;
  final FirebaseFirestore store;
  final GoogleSignIn google;
  final FlutterSecureStorage storage;
  final Future<void> Function() initializeGoogle;
  final AvatarPreferences avatars;

  User get user =>
      auth.currentUser ??
      (throw FirebaseAuthException(code: 'no-current-user'));
  void _owns(String uid) {
    if (user.uid != uid) throw FirebaseAuthException(code: 'user-mismatch');
  }

  AccountProfile snapshot({
    bool cloudSynced = true,
    String? fallbackName,
    String? fallbackAvatarId,
  }) {
    final current = user;
    final resolvedName =
        (current.displayName != null && current.displayName!.trim().isNotEmpty)
        ? current.displayName
        : (fallbackName != null && fallbackName.trim().isNotEmpty)
        ? fallbackName
        : current.displayName;
    final resolvedAvatar =
        AvatarCatalog.fromPhotoUrl(current.photoURL) ??
        (AvatarCatalog.valid(fallbackAvatarId) ? fallbackAvatarId : null) ??
        avatars.read(current.uid);
    return AccountProfile(
      user: AuthUser(
        id: current.uid,
        email: current.email,
        name: resolvedName,
        emailVerified: current.emailVerified,
        avatarId: resolvedAvatar,
        photoUrl: current.photoURL,
      ),
      passwordProvider: current.providerData.any(
        (p) => p.providerId == 'password',
      ),
      googleProvider: current.providerData.any(
        (p) => p.providerId == 'google.com',
      ),
      cloudSynced: cloudSynced,
    );
  }

  @override
  Future<AccountProfile> load() async {
    await user.reload();
    final uid = user.uid;
    String? cloudName;
    String? cloudAvatarId;
    try {
      final doc = await store
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 8));
      final data = doc.data();
      if (data != null) {
        final rawName = data['name'];
        if (rawName is String && rawName.trim().isNotEmpty) {
          cloudName = rawName.trim();
        }
        final rawAvatar = data['avatarId'];
        if (rawAvatar is String && AvatarCatalog.valid(rawAvatar)) {
          cloudAvatarId = rawAvatar;
          await avatars.write(uid, rawAvatar);
        }
      }
    } catch (_) {
      // Offline/unavailable cloud mirror falls back to Auth + local cache on load.
    }
    _owns(uid);
    return snapshot(
      fallbackName: cloudName,
      fallbackAvatarId: cloudAvatarId,
    );
  }

  @override
  Future<AccountProfile> save(String name, String avatarId) async {
    final uid = user.uid;
    await store
        .collection('users')
        .doc(uid)
        .set({
          'name': name,
          'avatarId': avatarId,
          'updatedAt': FieldValue.serverTimestamp(),
          'schemaVersion': 1,
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 12));
    _owns(uid);
    await user.updateDisplayName(name);
    _owns(uid);
    await user.updatePhotoURL(AvatarCatalog.photoUrl(avatarId));
    await avatars.write(uid, avatarId);
    _owns(uid);
    return snapshot(
      cloudSynced: true,
      fallbackName: name,
      fallbackAvatarId: avatarId,
    );
  }

  @override
  Future<void> verify() => user.sendEmailVerification();
  Future<void> reauthenticate(String password) async {
    final current = user;
    final uid = current.uid;
    if (current.providerData.any((p) => p.providerId == 'password')) {
      await current.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: current.email!, password: password),
      );
    } else if (current.providerData.any((p) => p.providerId == 'google.com')) {
      await initializeGoogle();
      final account = await google.authenticate();
      final token = account.authentication.idToken;
      if (token == null) {
        throw FirebaseAuthException(code: 'invalid-credential');
      }
      await current.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: token),
      );
    } else {
      throw FirebaseAuthException(code: 'unsupported-provider');
    }
    _owns(uid);
  }

  @override
  Future<void> changeEmail(String email, String password) async {
    final uid = user.uid;
    await reauthenticate(password);
    _owns(uid);
    await user.verifyBeforeUpdateEmail(email);
  }

  @override
  Future<void> changePassword(String password, String replacement) async {
    final uid = user.uid;
    if (!snapshot().passwordProvider) {
      throw FirebaseAuthException(code: 'unsupported-provider');
    }
    await reauthenticate(password);
    _owns(uid);
    await user.updatePassword(replacement);
  }

  @override
  Future<void> deleteAccount(String password) async {
    final uid = user.uid;
    await reauthenticate(password);
    _owns(uid);
    final profile = store.collection('users').doc(uid);
    final favorites = profile.collection('favorites');
    await AccountCleanup(
      assertIdentity: () => _owns(uid),
      preflight: () async {
        await profile.get(const GetOptions(source: Source.server));
        await favorites.limit(1).get(const GetOptions(source: Source.server));
      },
      deleteNextBatch: () async {
        final page = await favorites.limit(200).get(const GetOptions(source: Source.server));
        if (page.docs.isEmpty) return false;
        final batch = store.batch();
        for (final doc in page.docs) { batch.delete(doc.reference); }
        await batch.commit();
        return true;
      },
      deleteProfileAndVerify: () async {
        await profile.delete();
        if ((await profile.get(const GetOptions(source: Source.server))).exists ||
            (await favorites.limit(1).get(const GetOptions(source: Source.server))).docs.isNotEmpty) {
          throw FirebaseAuthException(code: 'cleanup-incomplete');
        }
      },
      clearLocal: () async {
        await storage.delete(key: 'chat_v1_${base64Url.encode(utf8.encode(uid))}');
        await avatars.remove(uid);
      },
      deleteIdentity: () => user.delete(),
    ).run();
  }
}
