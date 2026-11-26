import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/profile/data/datasources/account_datasource.dart';
import 'package:egy/features/profile/data/repositories/account_repository_impl.dart';
import 'package:egy/features/profile/domain/entities/account_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/account_repository.dart';

class Source implements AccountDatasource {
  final fixture = TestAccountRepository();
  int writes = 0;
  String? failure;
  Future<void> _operation() async { if (failure != null) throw FirebaseAuthException(code: failure!); }
  @override
  Future<AccountProfile> load() async => fixture.profile;
  @override
  Future<AccountProfile> save(String name, String avatarId) async { writes++; await _operation(); return fixture.save(name, avatarId); }
  @override
  Future<void> verify() => _operation();
  @override
  Future<void> changeEmail(String email, String password) => _operation();
  @override
  Future<void> changePassword(String password, String replacement) => _operation();
  @override
  Future<void> deleteAccount(String password) => _operation();
}
void main() {
  test('invalid avatar never reaches remote profile writes', () async {
    final source = Source(); final repository = AccountRepositoryImpl(source);
    await expectLater(repository.save('Test name', 'unexpected'), throwsA(isA<AuthFailure>()));
    expect(source.writes, 0);
  });
  test('profile save uses the same account and trims only display-name whitespace', () async {
    final source = Source(); final repository = AccountRepositoryImpl(source);
    final saved = await repository.save('  Updated name  ', 'yasmin');
    expect(saved.user.id, source.fixture.profile.user.id);
    expect(saved.user.name, 'Updated name'); expect(saved.user.avatarId, 'yasmin');
  });
  test('Firebase credential errors retain their typed actionable code', () async {
    final source = Source()..failure = 'requires-recent-login';
    await expectLater(AccountRepositoryImpl(source).changePassword('old', 'replacement'),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'code', 'requires-recent-login')));
  });
}
