import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';

import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../widgets/splash_sun_motion.dart';
import 'package:egy/app/router/app_motion.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:egy/features/splash/presentation/widgets/cairo_skyline_painter.dart';

/// Animated brand introduction screen.
///
/// Displays the Cairo skyline splash for ~5 seconds then navigates to
/// Onboarding (first run) or Login (returning user).
///
/// Animation timeline — 5 000 ms total:
///   0 –   800 ms: Ground line / mist fades in.
///   0 – 1 600 ms: Pyramid construction with worker silhouettes.
///   800 – 2 600 ms: Cairo skyline buildings descend.
///  1 400 – 2 600 ms: Nile slides in from the right.
///  2 200 – 2 900 ms: Sun follows a curved arc from the right.
///  2 900 – 3 300 ms: Workers leave; scaffolding fades.
///  3 200 – 3 700 ms: Fixed EGY logo is revealed by the passing sun.
///  3 700 – 4 100 ms: Sun and logo hold their final composition.
///  4 100 – 5 000 ms: Scene fades out → navigate.
///
/// [MediaQuery.disableAnimationsOf] is respected — reduced-motion users jump
/// to a settled frame immediately.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  bool _reduced = false;
  bool _started = false;
  bool _handedOff = false;
  bool _committed = false;
  String? _destination;
  final _handoff = ScreenHandoff(fromSplash: true);

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      animationBehavior: AnimationBehavior.preserve,
    )..addListener(_onClockTick);

    // Precache the logo so it is ready when it fades in at ~3.2 s.
    // We do this in initState (before the first build) to give the image
    // decoder as much time as possible without blocking the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/img/logo.png'), context);
      precacheImage(const AssetImage('assets/img/onboarding-1.png'), context);
      _maybeStart();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    final settle = reduced && !_reduced && _started;
    _reduced = reduced;
    if (settle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _clock.value = 1;
        if (_destination != null) {
          context.goNamed(_destination!);
        } else {
          _signalDone();
        }
      });
    }
  }

  /// Start the clock exactly once, deferred to after the first painted frame.
  ///
  /// Calling [_clock.forward()] here — rather than immediately in
  /// [didChangeDependencies] — means the 5-second timeline begins only when
  /// Flutter is actually rendering pixels, not during engine/Dart warm-up.
  /// This keeps the native ivory background visible during startup and ensures
  /// the user sees the full animation without any frames silently consumed.
  void _maybeStart() {
    if (_started || _clock.isAnimating || _clock.value != 0) return;
    _started = true;
    if (_reduced) {
      _clock.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _signalDone());
    } else {
      _clock.forward();
    }
  }

  void _onClockTick() {
    if (!_reduced) {
      _handoff.value =
          ((_clock.value - AppMotion.splashHandoff) /
                  (1 - AppMotion.splashHandoff))
              .clamp(0.0, 1.0);
    }
    _commitWhenFinished();
    if (!_reduced && _clock.value >= AppMotion.splashHandoff) {
      _signalDone();
    }
  }

  void _commitWhenFinished() {
    if (_clock.value != 1 || _destination == null || _committed || _reduced) {
      return;
    }
    _committed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.goNamed(_destination!);
    });
  }

  void _signalDone() {
    if (!mounted || _handedOff) return;
    _handedOff = true;
    context.read<SplashCubit>().onAnimationComplete();
  }

  @override
  void dispose() {
    _clock.dispose();
    _handoff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: _onStateChange,
      child: ColoredBox(
        color: AppPalette.canvas(context, AppColors.splashSurface),
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, bounds) {
                final width = bounds.maxWidth
                    .clamp(0.0, 520.0)
                    .toDouble()
                    .clamp(0.0, (bounds.maxHeight * 1.44).clamp(0.0, 520.0));
                final height = width * 0.64;
                return SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      // ── Skyline ──────────────────────────────────────────
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: CairoSkylinePainter(
                              _clock,
                              _reduced,
                              handoff: _handoff,
                              dark:
                                  Theme.of(context).brightness ==
                                  Brightness.dark,
                            ),
                          ),
                        ),
                      ),

                      // ── EGY Logo ─────────────────────────────────────────
                      Positioned(
                        top: 0,
                        left: width * .22,
                        right: width * .22,
                        height: width * .22,
                        child: AnimatedBuilder(
                          animation: _clock,
                          child: Image.asset(
                            'assets/img/logo.png',
                            key: const Key('splash_logo'),
                            fit: BoxFit.contain,
                            semanticLabel: 'EGY DEVELOPMENT',
                          ),
                          builder: (context, child) {
                            final ms = _clock.value * 5000;
                            final exit = _reduced
                                ? 0.0
                                : HandoffTiming.leave(_handoff.value, 3);
                            return Opacity(
                              opacity: 1 - exit,
                              child: Transform.scale(
                                scale: 1 - .04 * exit,
                                child: ClipRect(
                                  key: const Key('splash_logo_reveal'),
                                  clipper: SunLogoClipper(
                                    _reduced ? 1 : SplashSunMotion.reveal(ms),
                                  ),
                                  child: child,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, SplashState state) {
    if (state is! SplashDone) return;
    _destination = switch (state.destination) {
      SplashDestination.onboarding => RouteNames.onboarding,
      SplashDestination.login => RouteNames.login,
      SplashDestination.home => RouteNames.home,
    };
    if (_reduced) {
      context.goNamed(_destination!);
    } else {
      // Push keeps the actual skyline and its logo mounted through the exit.
      context.pushNamed<void>(_destination!, extra: _handoff);
      _commitWhenFinished();
    }
  }
}

/// Wraps [SplashPage] with a [SplashCubit] backed by the ambient
/// [SharedPreferences] from the widget tree.
class SplashPageWrapper extends StatelessWidget {
  const SplashPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => SplashCubit(
        context.read<SharedPreferences>(),
        authRepository: sl.isRegistered<AuthRepository>()
            ? sl<AuthRepository>()
            : null,
      ),
      child: const SplashPage(),
    );
  }
}
