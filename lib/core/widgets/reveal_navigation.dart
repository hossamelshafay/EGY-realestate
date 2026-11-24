import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

part 'reveal_surface.dart';

/// Reveals navigation beneath a stable, full-size navigator subtree.
class RevealNavigation extends StatefulWidget {
  const RevealNavigation({super.key, required this.child, this.menu});

  final Widget child;
  final Widget? menu;

  /// Whether the nearest shell supplies an authenticated menu.
  static bool availableOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_RevealAvailability>()
          ?.enabled ??
      false;

  /// Opens a menu on the current route so Android Back dismisses it first.
  static void open(BuildContext context) => context
      .findAncestorStateOfType<_RevealNavigationState>()
      ?._open(ModalRoute.of(context));

  /// Closes the menu before performing a route action.
  static void close(BuildContext context, {VoidCallback? onClosed}) => context
      .findAncestorStateOfType<_RevealNavigationState>()
      ?._close(onClosed);

  @override
  State<RevealNavigation> createState() => _RevealNavigationState();
}

class _RevealNavigationState extends State<RevealNavigation>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(vsync: this)
    ..addStatusListener(_settled);
  LocalHistoryEntry? _history;
  VoidCallback? _onClosed;
  bool _visible = false;
  bool _closing = false;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced && _motion.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _reduced) _motion.value = _closing ? 0 : 1;
      });
    }
  }

  @override
  void didUpdateWidget(covariant RevealNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.menu == null && _visible) {
      _onClosed = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.menu == null) _close();
      });
    }
  }

  void _open(ModalRoute<Object?>? route) {
    if (widget.menu == null || _visible || route == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _history = LocalHistoryEntry(
      impliesAppBarDismissal: false,
      onRemove: _reverse,
    );
    route.addLocalHistoryEntry(_history!);
    setState(() => _visible = true);
    _expand();
  }

  void _expand() {
    if (_reduced) {
      _motion.value = 1;
    } else {
      _motion.animateTo(
        1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _close([VoidCallback? onClosed]) {
    if (!_visible || _closing) return;
    _onClosed = onClosed;
    final history = _history;
    if (history == null) {
      _reverse();
    } else {
      history.remove();
    }
  }

  void _reverse() {
    _history = null;
    if (!mounted) return;
    _closing = true;
    if (_reduced || _motion.isDismissed) {
      _motion.value = 0;
      if (_visible) _settled(AnimationStatus.dismissed);
    } else {
      _motion.animateBack(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _settled(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !_closing || !mounted) return;
    setState(() {
      _visible = false;
      _closing = false;
    });
    final action = _onClosed;
    _onClosed = null;
    action?.call();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  void _drag(double fraction) {
    if (!_closing) _motion.value = (_motion.value + fraction).clamp(.001, 1);
  }

  void _endDrag(double velocity) {
    if (_closing) return;
    if (_motion.value < .78 || velocity < -300) {
      _close();
    } else {
      _expand();
    }
  }

  @override
  Widget build(BuildContext context) => _RevealAvailability(
    enabled: widget.menu != null,
    child: _RevealSurface(
      animation: _motion,
      visible: _visible,
      menu: widget.menu,
      onDismiss: _close,
      onDrag: _reduced ? null : _drag,
      onDragEnd: _reduced ? null : _endDrag,
      onDragCancel: _reduced
          ? null
          : () {
              if (!_closing) _expand();
            },
      child: widget.child,
    ),
  );
}

class _RevealAvailability extends InheritedWidget {
  const _RevealAvailability({required this.enabled, required super.child});
  final bool enabled;

  @override
  bool updateShouldNotify(_RevealAvailability oldWidget) =>
      enabled != oldWidget.enabled;
}
