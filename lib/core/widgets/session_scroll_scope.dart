import 'package:flutter/widgets.dart';

/// Marks content whose vertical scrolling is owned by the persistent shell.
class SessionScrollScope extends InheritedWidget {
  const SessionScrollScope({super.key, required super.child});
  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScrollScope>() != null;
  @override
  bool updateShouldNotify(SessionScrollScope oldWidget) => false;
}
