import 'package:material_ui/material_ui.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/core/widgets/session_morph_scope.dart';

/// One initial clock survives locale rebuilds and changes of authentication mode.
class AuthEntrance extends StatefulWidget {
  const AuthEntrance({super.key, required this.child});
  final Widget child;
  @override
  State<AuthEntrance> createState() => _AuthEntranceState();
}

class _AuthEntranceState extends State<AuthEntrance>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        HandoffScope.of(context)?.notifier != null) {
      _clock.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _clock.forward();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _AuthEntranceScope(notifier: _clock, child: widget.child);
}

class _AuthEntranceScope extends InheritedNotifier<AnimationController> {
  const _AuthEntranceScope({required super.notifier, required super.child});
}

/// Paints header, brand, title and fields progressively on the initial mount.
class AuthEntranceStage extends StatelessWidget {
  const AuthEntranceStage({
    super.key,
    required this.stage,
    required this.child,
    this.scale = false,
    this.exitOnHome = false,
  });
  final int stage;
  final Widget child;
  final bool scale;
  final bool exitOnHome;
  @override
  Widget build(BuildContext context) {
    final clock = context
        .dependOnInheritedWidgetOfExactType<_AuthEntranceScope>()
        ?.notifier;
    if (clock == null) return child;
    final shared = HandoffScope.of(context);
    final t = MediaQuery.disableAnimationsOf(context)
        ? 1.0
        : shared?.incoming == true
        ? shared?.notifier?.value ?? clock.value
        : clock.value;
    final start = switch (stage) {
      0 => .12,
      1 => .25,
      2 => .36,
      3 => .46,
      4 => .52,
      5 => .6,
      6 => .68,
      7 => .82,
      8 => .87,
      _ => .9,
    };
    final progress = HandoffTiming.enter(
      t,
      start,
      (start + .28).clamp(0.0, 1.0),
    );
    final morph = exitOnHome ? SessionMorphScope.of(context) : null;
    final exit = morph?.home == true
        ? HandoffTiming.leave(morph!.notifier!.value, (stage - 3).clamp(0, 3))
        : 0.0;
    return IgnorePointer(
      ignoring: progress == 0 || exit > 0,
      child: Opacity(
        key: ValueKey('auth_entrance_$stage'),
        opacity: progress * (1 - exit),
        child: Transform.translate(
          offset: Offset(
            0,
            stage == 0 ? -20 * (1 - progress) : 12 * (1 - progress) - 16 * exit,
          ),
          child: Transform.scale(
            scale: scale ? .94 + .06 * progress : 1,
            child: child,
          ),
        ),
      ),
    );
  }
}
