import 'package:egy/features/authentication/domain/entities/auth_user.dart';

/// Auth is authoritative; Firestore is a UID-scoped profile mirror.
class AccountProfile {
  const AccountProfile({
    required this.user,
    required this.passwordProvider,
    required this.googleProvider,
    this.cloudSynced = true,
  });
  final AuthUser user;
  final bool passwordProvider, googleProvider, cloudSynced;
}
