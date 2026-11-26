import '../entities/account_profile.dart';

abstract interface class AccountRepository {
  Future<AccountProfile> load();
  Future<AccountProfile> save(String name, String avatarId);
  Future<void> sendVerification();
  Future<void> changeEmail(String email, String password);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String password);
}
