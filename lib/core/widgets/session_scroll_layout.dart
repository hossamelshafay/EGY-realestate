import 'package:flutter/widgets.dart';

import 'package:egy/features/authentication/presentation/widgets/auth_entrance.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_shell_motion.dart';
import 'package:egy/features/home/presentation/widgets/drawer_scaffold.dart';
import 'session_header_metrics.dart';
import 'session_scroll_scope.dart';
import 'shared_session_header.dart';

/// Normal headers occupy their full curve extent in the primary scroll flow.
/// Only full-screen feedback temporarily reparents the SAME header above it.
class SessionScrollLayout extends StatefulWidget {
  const SessionScrollLayout({
    super.key,
    required this.metrics,
    required this.motion,
    required this.home,
    required this.auth,
    required this.homeContent,
  });
  final SessionHeaderMetrics metrics;
  final AuthShellMotion motion;
  final bool home;
  final Widget auth, homeContent;
  @override
  State<SessionScrollLayout> createState() => _SessionScrollLayoutState();
}

class _SessionScrollLayoutState extends State<SessionScrollLayout> {
  final _scroll = ScrollController(keepScrollOffset: false);
  final _header = GlobalKey();
  final _viewport = GlobalKey();
  Rect? _origin;
  double _switchOffset = 0;
  AuthMotionPhase _previous = AuthMotionPhase.idle;
  bool get _overlay => switch (widget.motion.phase) {
    AuthMotionPhase.idle || AuthMotionPhase.switching => false,
    _ => true,
  };

  @override
  void initState() {
    super.initState();
    widget.motion.addListener(_phaseChanged);
    widget.motion.mode.addListener(_foldScroll);
  }

  @override
  void didUpdateWidget(covariant SessionScrollLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home && !widget.home && _scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  void _phaseChanged() {
    final phase = widget.motion.phase;
    if (phase == _previous) return;
    if (phase == AuthMotionPhase.switching) {
      _switchOffset = _scroll.hasClients ? _scroll.offset : 0;
    }
    if (phase == AuthMotionPhase.expandingSuccess ||
        phase == AuthMotionPhase.expandingFailure) {
      // Cancel an in-flight drag/fling without moving the captured form.
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.offset);
      final header = _header.currentContext?.findRenderObject();
      final viewport = _viewport.currentContext?.findRenderObject();
      if (header is RenderBox && viewport is RenderBox) {
        final y = header.localToGlobal(Offset.zero, ancestor: viewport).dy;
        // Offscreen geometry can move invisibly to the viewport's top edge.
        _origin = Rect.fromLTWH(
          0,
          y.clamp(-header.size.height, 0.0),
          viewport.size.width,
          header.size.height,
        );
      }
    }
    if (phase == AuthMotionPhase.awaitingHome && _scroll.hasClients) {
      // The full navy cover hides this reset before Home is inserted.
      _scroll.jumpTo(0);
    }
    _previous = phase;
  }

  void _foldScroll() {
    if (!widget.motion.switching || !_scroll.hasClients) return;
    final offset =
        _switchOffset *
        (1 - Curves.easeInOutCubic.transform(widget.motion.mode.value));
    _scroll.jumpTo(offset.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  void dispose() {
    widget.motion.removeListener(_phaseChanged);
    widget.motion.mode.removeListener(_foldScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;
    final header = RepaintBoundary(
      key: _header,
      child: AuthEntranceStage(
        stage: 0,
        child: SharedSessionHeader(
          metrics: m,
          onMenu: () => DrawerScaffold.open(context),
        ),
      ),
    );
    final full = Rect.fromLTWH(0, 0, m.width, m.viewportHeight);
    final rect = widget.home
        ? Rect.fromLTWH(0, 0, m.width, m.height)
        : Rect.lerp(
            _origin ?? Rect.fromLTWH(0, 0, m.width, m.auth),
            full,
            widget.motion.cover.value,
          )!;
    return Stack(
      key: _viewport,
      fit: StackFit.expand,
      children: [
        SessionScrollScope(
          child: CustomScrollView(
            key: const Key('session_scroll'),
            controller: _scroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: widget.home ? m.height : m.auth,
                  child: _overlay ? null : header,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (!widget.home || !widget.motion.home.isCompleted)
                      Offstage(offstage: widget.home, child: widget.auth),
                    if (widget.home) widget.homeContent,
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_overlay) Positioned.fromRect(rect: rect, child: header),
      ],
    );
  }
}

