import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_entrance.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_motion_scope.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_shell_motion.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_style.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_result_cache.dart';
import 'package:egy/features/home/presentation/pages/home_page.dart';
import 'session_header_metrics.dart';
import 'session_morph_scope.dart';
import 'session_scroll_layout.dart';
import 'session_text_measurements.dart';

/// One route-stable shell owns the auth folds, full-screen result and Home reveal.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key, this.authMode});
  final AuthPageMode? authMode;
  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage>
    with TickerProviderStateMixin {
  late final AuthShellMotion _motion;
  final _measurements = SessionTextMeasurements();
  Widget? _authPage;
  AuthPageMode? _authPageMode;
  bool get _home => widget.authMode == null;
  @override
  void initState() {
    super.initState();
    AuthResultCache.instance.warmup();
    _motion = AuthShellMotion(
      vsync: this,
      initialMode: widget.authMode ?? AuthPageMode.login,
      initiallyHome: _home,
      onSuccessReady: _successReady,
    );
  }

  @override
  void didUpdateWidget(covariant SessionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authMode != null && oldWidget.authMode == null) {
      _motion.resetAuth(widget.authMode!);
    } else if (widget.authMode != null &&
        oldWidget.authMode != widget.authMode) {
      unawaited(_motion.switchTo(widget.authMode!));
    } else if (_home && oldWidget.authMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_motion.reduced || _motion.phase == AuthMotionPhase.awaitingHome) {
          _motion.revealHome();
        } else if (!_motion.busy) {
          unawaited(_motion.showSuccess());
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced && !_motion.reduced) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _motion.settleReducedMotion();
      });
    }
    _motion.reduced = reduced;
  }

  void _onAuthState(AuthState state) {
    if (state is AuthLoading) {
      _motion.setLoading(true);
      _motion.clearError();
      return;
    }
    _motion.setLoading(false);
    if (state is! AuthResetSent) FocusManager.instance.primaryFocus?.unfocus();
    if (state is AuthSuccess) {
      unawaited(_motion.showSuccess());
    }
    if (state is AuthError) {
      unawaited(_motion.showFailure(state.code, state.attempt));
    }
  }

  void _successReady() {
    if (!mounted) return;
    final session = sl.isRegistered<SessionCubit>() ? sl<SessionCubit>() : null;
    if (session != null && session.state.user == null) {
      _motion.errorCode = 'unknown';
      unawaited(_motion.returnToForm());
      return;
    }
    if (_home) {
      _motion.revealHome();
      return;
    }
    session?.completeFeedback();
    // Auth may have been pushed over onboarding. A router refresh evaluates
    // that base route, so explicitly commit Home after feedback completes.
    context.goNamed(RouteNames.home);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content(String? name) => AuthEntrance(
      child: AuthStyle(
        child: AuthMotionScope(
          motion: _motion,
          child: SessionMorphScope(
            progress: _motion.home,
            home: _home,
            child: AnimatedBuilder(
              animation: _motion,
              builder: (context, _) => HandoffSurface(
                color: AppColors.white,
                child: PopScope(
                  canPop: !_motion.busy,
                  child: IgnorePointer(
                    ignoring: _motion.busy,
                    child: LayoutBuilder(
                      builder: (context, bounds) {
                        final metrics = SessionHeaderMetrics(
                          context,
                          bounds.biggest,
                          _motion,
                          name,
                          measurements: _measurements,
                        );
                        if (_authPageMode != _motion.visibleMode ||
                            _authPage == null) {
                          _authPageMode = _motion.visibleMode;
                          _authPage = AuthPage(
                            key: const Key('session_auth'),
                            mode: _motion.visibleMode,
                            onState: _onAuthState,
                          );
                        }
                        return SessionScrollLayout(
                          metrics: metrics,
                          motion: _motion,
                          home: _home,
                          auth: _authPage!,
                          homeContent: const HomePage(key: Key('session_home')),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final body = !sl.isRegistered<SessionCubit>()
        ? content(null)
        : BlocBuilder<SessionCubit, SessionState>(
            bloc: sl<SessionCubit>(),
            buildWhen: (before, after) => before.user?.name != after.user?.name,
            builder: (context, state) => content(state.user?.name),
          );
    // Production uses DrawerScaffold; isolated Auth routes still need Material.
    return Scaffold.maybeOf(context) == null
        ? Scaffold(backgroundColor: AppColors.transparent, body: body)
        : body;
  }
}
