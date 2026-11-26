import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'theme_cubit.dart';
import 'app_colors.dart';

/// Keeps one live navigator; outgoing pixels exist only in memory during reveal.
class ThemeReveal extends StatefulWidget {
  const ThemeReveal({super.key, required this.child, required this.router});
  final Widget child;
  final GoRouter router;

  static Future<void> select(BuildContext toggle, ThemeMode mode) async {
    final host = toggle.findAncestorStateOfType<_ThemeRevealState>();
    if (host == null) {
      await toggle.read<ThemeCubit>().select(mode);
      return;
    }
    final box = toggle.findRenderObject();
    final center = box is RenderBox
        ? box.localToGlobal(box.size.center(Offset.zero))
        : MediaQuery.sizeOf(toggle).center(Offset.zero);
    await host.select(mode, center);
  }

  @override
  State<ThemeReveal> createState() => _ThemeRevealState();
}

class _ThemeRevealState extends State<ThemeReveal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _surface = GlobalKey();
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  ui.Image? _outgoing;
  Offset _origin = Offset.zero;
  bool _wasDark = false;
  bool _busy = false;
  int _epoch = 0;
  (ThemeMode, Offset)? _queued;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.router.routeInformationProvider.addListener(_cancel);
    _clock.addStatusListener((status) {
      if (status == AnimationStatus.completed) _clear();
    });
  }

  void _clear() {
    final image = _outgoing;
    if (image == null || !mounted) return;
    setState(() => _outgoing = null);
    WidgetsBinding.instance.addPostFrameCallback((_) => image.dispose());
  }

  void _cancel() {
    _epoch++;
    _clock.stop();
    _clear();
  }

  @override
  void didChangeMetrics() => _cancel();

  @override
  void didChangePlatformBrightness() => _cancel();

  Future<void> select(ThemeMode mode, Offset origin) async {
    if (_busy) {
      _queued = (mode, origin);
      return;
    }
    _busy = true;
    try {
      _cancel();
      final epoch = _epoch;
      final controller = context.read<ThemeCubit>();
      final wasDark = Theme.of(context).brightness == Brightness.dark;
      final willBeDark = mode == ThemeMode.dark;
      if (MediaQuery.disableAnimationsOf(context) || wasDark == willBeDark) {
        await controller.select(mode);
        return;
      }
      RenderRepaintBoundary? boundary;
      for (var frame = 0; frame < 4; frame++) {
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        final surface = _surface.currentContext?.findRenderObject();
        if (surface is RenderRepaintBoundary && !surface.debugNeedsPaint) {
          boundary = surface;
          break;
        }
      }
      if (boundary == null) {
        await controller.select(mode);
        return;
      }
      // No file, external capture, logging or second widget tree. Dispose promptly.
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.devicePixelRatioOf(context).clamp(1, 2),
      );
      if (!mounted) {
        image.dispose();
        return;
      }
      if (epoch != _epoch) {
        image.dispose();
        await controller.select(mode);
        return;
      }

      final hostBox = context.findRenderObject()! as RenderBox;
      setState(() {
        _origin = hostBox.globalToLocal(origin);
        _wasDark = wasDark;
        _outgoing = image;
      });
      await controller.select(mode);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted && _outgoing != null) {
        await _clock.forward(from: 0).orCancel;
      }
    } on TickerCanceled {
      // Navigation / resize cancels the visual layer, never the selected mode.
    } catch (_) {
      _clear();
      if (mounted) await context.read<ThemeCubit>().select(mode);
    } finally {
      _busy = false;
      final queued = _queued;
      _queued = null;
      if (mounted && queued != null) await select(queued.$1, queued.$2);
    }
  }

  @override
  void didUpdateWidget(ThemeReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routeInformationProvider.removeListener(_cancel);
      widget.router.routeInformationProvider.addListener(_cancel);
      _cancel();
    }
  }

  @override
  void dispose() {
    widget.router.routeInformationProvider.removeListener(_cancel);
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    _outgoing?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) && _outgoing != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cancel());
    }
    final path = widget.router.routeInformationProvider.value.uri.path;
    final onboarding = path == '/onboarding';
    final plainTop = onboarding || path == '/';
    final dark = !onboarding && Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark || !plainTop
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: onboarding ? AppColors.onboardingSurface : Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(key: _surface, child: widget.child),
          if (_outgoing case final image?)
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: AnimatedBuilder(
                    animation: _clock,
                    builder: (context, _) => ClipPath(
                      key: const Key('theme_circular_reveal'),
                      clipper: ThemeCircleClipper(
                        origin: _origin,
                        progress: Curves.easeInOutCubic.transform(_clock.value),
                        darkToLight: _wasDark,
                      ),
                      child: RawImage(image: image, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dark expands from the toggle; on return, the outgoing dark disk contracts.
class ThemeCircleClipper extends CustomClipper<Path> {
  const ThemeCircleClipper({
    required this.origin,
    required this.progress,
    required this.darkToLight,
  });
  final Offset origin;
  final double progress;
  final bool darkToLight;

  static double coveringRadius(Size size, Offset origin) => [
    Offset.zero,
    Offset(size.width, 0),
    Offset(0, size.height),
    Offset(size.width, size.height),
  ].map((corner) => (corner - origin).distance).reduce(math.max);

  @override
  Path getClip(Size size) {
    final radius =
        coveringRadius(size, origin) * (darkToLight ? 1 - progress : progress);
    final disk = Path()
      ..addOval(Rect.fromCircle(center: origin, radius: radius));
    return darkToLight
        ? disk
        : (Path()
            ..fillType = PathFillType.evenOdd
            ..addRect(Offset.zero & size)
            ..addPath(disk, Offset.zero));
  }

  @override
  bool shouldReclip(ThemeCircleClipper old) =>
      origin != old.origin ||
      progress != old.progress ||
      darkToLight != old.darkToLight;
}
