import '../../domain/entities/account_profile.dart';

abstract interface class AccountDatasource {
  Future<AccountProfile> load();
  Future<AccountProfile> save(String name, String avatarId);
  Future<void> verify();
  Future<void> changeEmail(String email, String password);
  Future<void> changePassword(String password, String replacement);
  Future<void> deleteAccount(String password);
}
