import 'package:egy/app/di/injection.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import 'package:egy/features/profile/domain/entities/account_profile.dart';
import 'package:egy/features/profile/domain/repositories/account_repository.dart';
import 'package:egy/features/profile/presentation/cubit/account_cubit.dart';

class TestAccountRepository implements AccountRepository {
  AccountProfile profile = const AccountProfile(user: AuthUser(id: 'test-profile',
    name: 'Test profile', email: 'test@example.com', avatarId: 'nile', emailVerified: true),
    passwordProvider: true, googleProvider: false);
  String? failure;
  bool synced = true;
  final calls = <String>[];
  @override
  Future<AccountProfile> load() async => profile;
  void _check(String action) {
    calls.add(action);
    if (failure != null) throw AuthFailure(failure!);
  }
  @override
  Future<AccountProfile> save(String name, String avatarId) async {
    _check('save');
    profile = AccountProfile(user: AuthUser(id: profile.user.id, name: name,
      email: profile.user.email, emailVerified: profile.user.emailVerified, avatarId: avatarId),
      passwordProvider: profile.passwordProvider, googleProvider: profile.googleProvider,
      cloudSynced: synced);
    return profile;
  }
  @override
  Future<void> sendVerification() async => _check('verify');
  @override
  Future<void> changeEmail(String email, String password) async => _check('email');
  @override
  Future<void> changePassword(String currentPassword, String newPassword) async => _check('password');
  @override
  Future<void> deleteAccount(String password) async => _check('delete');
}

TestAccountRepository registerTestAccount() {
  final repository = TestAccountRepository();
  sl.registerSingleton<AccountRepository>(repository);
  sl.registerFactory(() => AccountCubit(sl<AccountRepository>()));
  return repository;
}
