import 'package:egy/core/errors/failures.dart';

/// Keeps Auth intact on preflight failures and exposes partial-cleanup failures.
class AccountCleanup {
  const AccountCleanup({required this.preflight, required this.deleteNextBatch,
    required this.deleteProfileAndVerify, required this.clearLocal,
    required this.deleteIdentity, required this.assertIdentity});
  final Future<void> Function() preflight, deleteProfileAndVerify, clearLocal, deleteIdentity;
  final Future<bool> Function() deleteNextBatch;
  final void Function() assertIdentity;

  Future<void> run() async {
    assertIdentity();
    await preflight();
    try {
      while (true) {
        assertIdentity();
        if (!await deleteNextBatch()) break;
      }
      assertIdentity();
      await deleteProfileAndVerify();
      await clearLocal();
      assertIdentity();
      await deleteIdentity();
    } catch (_) {
      throw const CacheFailure('cleanup-incomplete');
    }
  }
}
