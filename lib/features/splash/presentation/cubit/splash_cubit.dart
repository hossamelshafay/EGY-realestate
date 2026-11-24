import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';

import 'package:egy/core/constants/app_constants.dart';

// ── States ──────────────────────────────────────────────────────────────────

/// Represents the full lifecycle of the animated splash sequence.
sealed class SplashState {
  const SplashState();
}

/// Animation is running; UI should play the intro sequence.
final class SplashAnimating extends SplashState {
  const SplashAnimating();
}

/// Animation finished. Navigate to [destination].
final class SplashDone extends SplashState {
  const SplashDone({required this.destination});

  /// First-run, signed-out returning, or authenticated returning destination.
  final SplashDestination destination;
}

/// Where the app should navigate after the splash.
enum SplashDestination { onboarding, login, home }

// ── Cubit ───────────────────────────────────────────────────────────────────

/// Determines the post-splash navigation target and signals when the
/// animation sequence is complete.
///
/// Navigation is triggered by the view calling [onAnimationComplete] once
/// the animation actually finishes — never by an independent timer.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._prefs, {this._authRepository})
    : super(const SplashAnimating());

  final SharedPreferences _prefs;
  final AuthRepository? _authRepository;

  /// Called by the view when the full splash animation sequence has ended.
  void onAnimationComplete() {
    if (isClosed) return;
    final done = _prefs.getBool(AppConstants.prefOnboardingDone) == true;
    emit(
      SplashDone(
        destination: _authRepository?.currentUser != null
            ? SplashDestination.home
            : done
            ? SplashDestination.login
            : SplashDestination.onboarding,
      ),
    );
  }
}
