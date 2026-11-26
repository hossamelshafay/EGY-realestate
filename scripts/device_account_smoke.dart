import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/firebase_options.dart';

/// Alternate test entrypoint. Every auth operation uses ONLY a secondary app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Verifying disposable account. Your primary account is unchanged.')))));
  final result = <String, Object?>{'checks': <String>[], 'cleanup': false};
  final checks = result['checks']! as List<String>;
  FirebaseApp? app;
  FirebaseAuth? auth;
  String? createdUid;
  String? cleanupEmail, cleanupPassword;
  try {
    app = await Firebase.initializeApp(name: 'egy-ui-disposable-check', options: DefaultFirebaseOptions.currentPlatform);
    auth = FirebaseAuth.instanceFor(app: app);
    final random = Random.secure();
    final suffix = List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
    final email = 'egy-ui-check-$suffix@example.invalid';
    final password = 'EgY!${suffix}a1';
    cleanupEmail = email;
    cleanupPassword = password;
    final replacement = '${password}b2';
    final created = await auth.createUserWithEmailAndPassword(email: email, password: password);
    createdUid = created.user!.uid;
    await File('/data/data/com.example.egy/files/account_ui_verification.json').writeAsString(jsonEncode({'cleanupUid': createdUid, 'cleanup': false}));
    checks.add('registration');
    await created.user!.updateDisplayName('EGY disposable account check');
    await created.user!.updatePhotoURL('https://avatars.egy.local/lotus');
    await auth.signOut();
    final restored = (await auth.signInWithEmailAndPassword(email: email, password: password)).user!;
    if (restored.uid != createdUid || restored.displayName != 'EGY disposable account check' ||
        restored.photoURL != 'https://avatars.egy.local/lotus') {
      throw StateError('profile-restore-mismatch');
    }
    checks.add('name-and-avatar-after-logout-login');
    await restored.reauthenticateWithCredential(EmailAuthProvider.credential(email: email, password: password));
    await restored.updatePassword(replacement);
    cleanupPassword = replacement;
    await auth.signOut();
    var oldRejected = false;
    try { await auth.signInWithEmailAndPassword(email: email, password: password); }
    on FirebaseAuthException { oldRejected = true; }
    if (!oldRejected) throw StateError('old-password-accepted');
    final latest = (await auth.signInWithEmailAndPassword(email: email, password: replacement)).user!;
    if (latest.uid != createdUid) throw StateError('identity-changed');
    checks.add('reauthentication-and-password-change');
    try {
      await FirebaseFirestore.instanceFor(app: app).collection('users').doc(createdUid)
          .get(const GetOptions(source: Source.server));
      checks.add('cloud-profile-read-allowed');
    } on FirebaseException catch (error) {
      result['cloudProfileAccess'] = error.code;
    }
    result['success'] = true;
  } on FirebaseAuthException catch (error) {
    result['success'] = false;
    result['code'] = error.code;
  } catch (error) {
    result['success'] = false;
    result['code'] = error.runtimeType.toString();
  } finally {
    if (createdUid != null && auth?.currentUser == null && cleanupEmail != null) {
      try { await auth!.signInWithEmailAndPassword(email: cleanupEmail, password: cleanupPassword!); }
      catch (_) { result['cleanupUid'] = createdUid; }
    }
    if (createdUid != null && auth?.currentUser?.uid == createdUid) {
      try { await auth!.currentUser!.delete(); result['cleanup'] = true; }
      catch (_) { result['cleanupUid'] = createdUid; }
    } else if (createdUid == null) {
      result['cleanup'] = true;
    } else {
      result['cleanupUid'] = createdUid;
    }
    // This private test result contains no email, password, token or API key.
    await File('/data/data/com.example.egy/files/account_ui_verification.json').writeAsString(jsonEncode(result));
    if (app != null) await app.delete();
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text(
      result['success'] == true ? 'Disposable account checks complete. Restoring EGY next.' : 'Verification ended. Restoring EGY next.')))));
  }
}
