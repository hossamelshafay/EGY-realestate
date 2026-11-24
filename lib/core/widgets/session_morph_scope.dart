import 'package:flutter/widgets.dart';

/// One persistent shell clock coordinates header geometry, form exit and Home.
class SessionMorphScope extends InheritedNotifier<AnimationController> {
  const SessionMorphScope({
    super.key,
    required AnimationController progress,
    required this.home,
    required super.child,
  }) : super(notifier: progress);
  final bool home;
  static SessionMorphScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionMorphScope>();
  @override
  bool updateShouldNotify(covariant SessionMorphScope oldWidget) =>
      home != oldWidget.home || super.updateShouldNotify(oldWidget);
}
