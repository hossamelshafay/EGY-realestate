import 'package:flutter/widgets.dart';

import 'auth_shell_motion.dart';

/// Shared element motion survives auth routes, locale updates and Firebase events.
class AuthMotionScope extends InheritedNotifier<AuthShellMotion> {
  const AuthMotionScope({
    super.key,
    required AuthShellMotion motion,
    required super.child,
  }) : super(notifier: motion);
  static AuthShellMotion? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AuthMotionScope>()?.notifier;
  static AuthShellMotion? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthMotionScope>()?.notifier;
}
