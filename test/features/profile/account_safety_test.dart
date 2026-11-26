import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/profile/data/datasources/account_cleanup.dart';
import 'package:egy/features/profile/presentation/cubit/account_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/account_repository.dart';

void main() {
  test('unavailable cloud mirror fails truthfully without reporting success', () async {
    final repository = TestAccountRepository()..synced = false;
    final cubit = AccountCubit(repository);
    await cubit.load(); await cubit.save('New name', 'lotus');
    final state = cubit.state as AccountReady;
    expect(state.profile.user.name, 'Test profile');
    expect(state.profile.user.avatarId, 'nile');
    expect(state.error, 'cloud-sync-pending');
    expect(state.notice, isNull);
    await cubit.close();
  });
  test('credential rejection retains profile and exposes actionable error', () async {
    final repository = TestAccountRepository()..failure = 'invalid-credential';
    final cubit = AccountCubit(repository);
    await cubit.load(); await cubit.password('incorrect', 'replacement');
    final state = cubit.state as AccountReady;
    expect(state.profile.user.email, 'test@example.com');
    expect(state.error, 'invalid-credential');
    await cubit.close();
  });
  test('denied cleanup preflight makes no destructive calls', () async {
    final events = <String>[];
    final cleanup = AccountCleanup(assertIdentity: () {},
      preflight: () async => throw const CacheFailure('permission-denied'),
      deleteNextBatch: () async { events.add('favorites'); return false; },
      deleteProfileAndVerify: () async { events.add('profile'); },
      clearLocal: () async { events.add('local'); },
      deleteIdentity: () async { events.add('auth'); });
    await expectLater(cleanup.run(), throwsA(isA<CacheFailure>()));
    expect(events, isEmpty);
  });
  test('partial cleanup never deletes identity and reports incomplete cleanup', () async {
    var authDeleted = false;
    final cleanup = AccountCleanup(assertIdentity: () {}, preflight: () async {},
      deleteNextBatch: () async => throw const NetworkFailure(),
      deleteProfileAndVerify: () async {}, clearLocal: () async {},
      deleteIdentity: () async { authDeleted = true; });
    await expectLater(cleanup.run(), throwsA(isA<CacheFailure>().having((e) => e.message, 'code', 'cleanup-incomplete')));
    expect(authDeleted, isFalse);
  });
  test('identity is removed only after verified remote cleanup and local removal', () async {
    final events = <String>[];
    var first = true;
    final cleanup = AccountCleanup(assertIdentity: () {}, preflight: () async { events.add('preflight'); },
      deleteNextBatch: () async { if (first) { first = false; events.add('favorites'); return true; } return false; },
      deleteProfileAndVerify: () async { events.add('verified-profile'); },
      clearLocal: () async { events.add('local'); }, deleteIdentity: () async { events.add('auth'); });
    await cleanup.run();
    expect(events, ['preflight', 'favorites', 'verified-profile', 'local', 'auth']);
  });
}
