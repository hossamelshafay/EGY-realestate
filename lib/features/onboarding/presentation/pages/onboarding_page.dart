import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/app/theme/app_palette.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/app/router/app_motion.dart';
import 'package:egy/core/widgets/locale_selector.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_assets.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/onboarding_entrance.dart';

/// Three vertically swipeable onboarding pages with finger-driven animations.
///
/// Every visual effect (illustration translate/scale/opacity, text fade,
/// indicator size) is wired directly to [PageController.page] so movement
/// follows the user's finger continuously — including partial swipes,
/// slow drags, and reversals.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, this.fromSplash = false});
  final bool fromSplash;
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.light,
    child: OnboardingEntrance(
      enabled: fromSplash,
      child: BlocProvider(
        create: (_) => OnboardingCubit(context.read<SharedPreferences>()),
        child: const _OnboardingView(),
      ),
    ),
  );
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();
  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView>
    with SingleTickerProviderStateMixin {
  final _handoff = ScreenHandoff();
  late final AnimationController _exit;
  final PageController _ctrl = PageController();
  final _navigating = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _exit = AnimationController(vsync: this, duration: AppMotion.navigation);
    _exit.addListener(() => _handoff.value = _exit.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/img/logo.png'), context);
    for (final asset in OnboardingAssets.illustrations) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    _exit.dispose();
    _navigating.dispose();
    _handoff.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _finish(String route) async {
    if (_navigating.value) return;
    _navigating.value = true;
    try {
      final cubit = context.read<OnboardingCubit>();
      final success =
          cubit.state is OnboardingCompleted || await cubit.complete();
      if (!success || !mounted) return;
      final destination = context.pushNamed<void>(route, extra: _handoff);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (MediaQuery.disableAnimationsOf(context)) {
          _exit.value = 1;
        } else {
          _exit.forward(from: 0);
        }
      });
      await destination;
      if (mounted) {
        if (MediaQuery.disableAnimationsOf(context)) {
          _exit.value = 0;
        } else {
          await _exit.reverse();
        }
      }
    } finally {
      if (mounted) _navigating.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final titles = [l.onboardingTitle1, l.onboardingTitle2, l.onboardingTitle3];
    final descriptions = [
      l.onboardingDescription1,
      l.onboardingDescription2,
      l.onboardingDescription3,
    ];
    return HandoffSurface(
      color: AppPalette.canvas(context, AppColors.onboardingSurface),
      child: HandoffScope(
        handoff: _handoff,
        incoming: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([_exit, _navigating]),
          builder: (context, child) =>
              IgnorePointer(ignoring: _navigating.value, child: child),
          child: Scaffold(
            backgroundColor: AppColors.transparent,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) => Stack(
                      children: [
                        PageView.builder(
                          key: const Key('onboarding_pages'),
                          controller: _ctrl,
                          scrollDirection: Axis.vertical,
                          itemCount: 3,
                          onPageChanged: context
                              .read<OnboardingCubit>()
                              .pageChanged,
                          itemBuilder: (context, index) => AnimatedBuilder(
                            animation: _ctrl,
                            builder: (context, _) {
                              final page =
                                  _ctrl.hasClients &&
                                      _ctrl.position.haveDimensions
                                  ? _ctrl.page ?? 0.0
                                  : 0.0;
                              final reduced = MediaQuery.disableAnimationsOf(
                                context,
                              );
                              final motion = reduced
                                  ? 0.0
                                  : (page - index).clamp(-1.0, 1.0);
                              return OnboardingSlide(
                                index: index,
                                title: titles[index],
                                description: descriptions[index],
                                motion: motion,
                                pageController: _ctrl,
                                state: state,
                                onFinish: _finish,
                              );
                            },
                          ),
                        ),

                        // ── Smooth page indicators overlay ────────────────────────
                        PositionedDirectional(
                          top: 0,
                          start: 16,
                          child: AnimatedBuilder(
                            animation: _ctrl,
                            builder: (context, _) {
                              final page =
                                  _ctrl.hasClients &&
                                      _ctrl.position.haveDimensions
                                  ? _ctrl.page ?? 0.0
                                  : 0.0;
                              final visible = (1 - page).clamp(0.0, 1.0);
                              return IgnorePointer(
                                ignoring: visible == 0,
                                child: OnboardingEntranceStage(
                                  stage: 3,
                                  child: Opacity(
                                    opacity: visible,
                                    child: const LocaleSelector(
                                      compact: true,
                                      keyPrefix: 'onboarding_language',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _ctrl,
                            builder: (context, _) {
                              final page =
                                  _ctrl.hasClients &&
                                      _ctrl.position.haveDimensions
                                  ? _ctrl.page ?? 0.0
                                  : 0.0;
                              return OnboardingEntranceStage(
                                stage: 3,
                                enabled: true,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (i) {
                                    final distance = (page - i).abs().clamp(
                                      0.0,
                                      1.0,
                                    );
                                    final size = 10.0 - 3.0 * distance;
                                    return AnimatedContainer(
                                      key: Key('indicator_$i'),
                                      duration: Duration.zero,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      width: size,
                                      height: size,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.lerp(
                                          AppColors.onboardingGold,
                                          AppColors.indicatorInactive,
                                          distance,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                        ),

                        // ── Skip button ───────────────────────────────────────────
                        AnimatedBuilder(
                          animation: _ctrl,
                          builder: (context, _) {
                            final page =
                                _ctrl.hasClients &&
                                    _ctrl.position.haveDimensions
                                ? _ctrl.page ?? 0.0
                                : 0.0;
                            // Hide skip when approaching / past page 2
                            final opacity = (1.0 - (page - 1.5).clamp(0.0, 1.0))
                                .clamp(0.0, 1.0);
                            if (opacity <= 0) return const SizedBox.shrink();
                            return PositionedDirectional(
                              top: 0,
                              end: 16,
                              child: OnboardingEntranceStage(
                                stage: 3,
                                enabled: true,
                                child: Opacity(
                                  opacity: opacity,
                                  child: TextButton(
                                    key: const Key('skip'),
                                    onPressed: () {
                                      if (MediaQuery.disableAnimationsOf(
                                        context,
                                      )) {
                                        _ctrl.jumpToPage(2);
                                      } else {
                                        _ctrl.animateToPage(
                                          2,
                                          duration: const Duration(
                                            milliseconds: 420,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: Text(
                                      l.skip,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
