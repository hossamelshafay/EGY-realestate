import 'package:egy/app/localization/generated/app_localizations.dart';

/// Never displays raw Firebase messages, user credentials, or stack traces.
String accountMessage(AppLocalizations l, String code) => switch (code) {
  'saved' => l.profileSaved,
  'cloud-sync-pending' => l.profileSyncPending,
  'verification-sent' => l.verificationSent,
  'email-verification-sent' => l.emailChangeSent,
  'email-updated' => l.emailUpdated,
  'password-changed' => l.passwordChanged,
  'expired-action-code' || 'invalid-action-code' => l.emailLinkExpired,
  'permission-denied' => l.accountPermission,
  'cleanup-incomplete' => l.accountCleanupIncomplete,
  'wrong-password' ||
  'invalid-credential' ||
  'reauthentication-failed' ||
  'user-mismatch' ||
  'requires-recent-login' => l.accountReauthError,
  'email-already-in-use' => l.emailInUse,
  'invalid-email' => l.invalidEmail,
  'weak-password' => l.accountPasswordRules,
  'too-many-requests' => l.accountTryLater,
  'unsupported-provider' => l.accountProviderManaged,
  'invalid-profile' => l.accountNameRules,
  _ => l.accountUnavailable,
};
