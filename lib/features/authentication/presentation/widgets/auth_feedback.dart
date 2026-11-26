import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'auth_motion_scope.dart';

/// Backend codes never become raw visible text or distinguish unknown accounts.
String authErrorMessage(AppLocalizations l, String code) => switch (code) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' => l.invalidCredentials,
  'email-already-in-use' => l.emailInUse,
  'profile-save-partial' => l.authProfilePartial,
  'network-request-failed' => l.authNetwork,
  'cancelled' => l.authCancelled,
  _ => l.authGeneric,
};

/// Inline feedback is held until the first failure cover has returned to the form.
class AuthInlineError extends StatelessWidget {
  const AuthInlineError({super.key});
  @override
  Widget build(BuildContext context) {
    final motion = AuthMotionScope.read(context);
    if (motion == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: motion.feedback,
      builder: (context, _) {
        if (!motion.inlineReady || motion.errorCode == null) {
          return const SizedBox.shrink();
        }
        return Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              authErrorMessage(AppLocalizations.of(context), motion.errorCode!),
              key: const Key('auth_inline_error'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.destructiveRed),
            ),
          ),
        );
      },
    );
  }
}

/// Only fields implicated by credential errors shake and briefly receive red ink.
class AuthFeedbackField extends StatelessWidget {
  const AuthFeedbackField({
    super.key,
    required this.fieldKey,
    required this.child,
  });
  final Key? fieldKey;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final motion = AuthMotionScope.read(context);
    if (motion == null) return child;
    return AnimatedBuilder(
      animation: Listenable.merge([motion.feedback, motion.shake]),
      child: child,
      builder: (context, stableChild) {
        final email = fieldKey == const Key('auth_email');
        final password =
            fieldKey == const Key('auth_password') ||
            fieldKey == const Key('auth_confirm_password');
        final relevant = switch (motion.errorCode) {
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' => email || password,
          'email-already-in-use' => email,
          'weak-password' => password,
          _ => false,
        };

        final t = motion.shake.value;
        final active =
            relevant &&
            motion.shake.isAnimating &&
            !MediaQuery.disableAnimationsOf(context);
        final alpha = active ? math.sin(math.pi * t) : 0.0;
        final theme = Theme.of(context);
        final border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.destructiveRed.withValues(alpha: alpha),
            width: 1.5,
          ),
        );
        return Transform.translate(
          key: ValueKey('shake_$fieldKey'),
          offset: Offset(
            active ? math.sin(8 * math.pi * t) * 8 * (1 - t) : 0,
            0,
          ),
          child: Theme(
            data: active
                ? theme.copyWith(
                    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  )
                : theme,
            // AnimatedBuilder exposes Widget?; retain the required field fallback.
            child: stableChild ?? child,
          ),
        );
      },
    );
  }
}
