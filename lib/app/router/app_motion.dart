import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'screen_handoff.dart';

/// Routes retain both surfaces; only widgets consume the shared handoff clock.
abstract final class AppMotion {
  static const navigation = Duration(milliseconds: 1000);
  static const splashOverlap = navigation;
  static const splashHandoff = .8;

  static CustomTransitionPage<void> page({
    required BuildContext context,
    required LocalKey key,
    required Widget child,
    Duration duration = navigation,
  }) => CustomTransitionPage<void>(
    key: key,
    opaque: false,
    maintainState: true,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration,
    reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) => child,
  );

  /// Blends the incoming route over the retained route beneath it.
  static CustomTransitionPage<void> authenticatedPage({
    required BuildContext context,
    required LocalKey key,
    required Widget child,
  }) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 400);
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        return FadeTransition(
          key: const Key('authenticated_route_fade'),
          opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }
}

/// Outgoing content consumes the very same progress as destination elements.
class RouteMotionStage extends StatelessWidget {
  const RouteMotionStage({super.key, required this.child, this.stage = 0});
  final Widget child;
  final int stage;
  @override
  Widget build(BuildContext context) {
    final scope = HandoffScope.of(context);
    if (scope == null ||
        scope.incoming ||
        MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final exit = HandoffTiming.leave(scope.notifier?.value ?? 0, stage);
    return IgnorePointer(
      ignoring: exit > 0,
      child: Opacity(
        key: ValueKey('handoff_exit_$stage'),
        opacity: 1 - exit,
        child: Transform.translate(offset: Offset(0, -16 * exit), child: child),
      ),
    );
  }
}
