import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/core/constants/app_constants.dart';

/// Immutable onboarding progress and persistence status.
sealed class OnboardingState {
  const OnboardingState(this.page);
  final int page;
}

/// A page is ready for interaction.
final class OnboardingReady extends OnboardingState {
  const OnboardingReady(super.page, {this.error = false});
  final bool error;
}

/// Completion is being saved.
final class OnboardingSaving extends OnboardingState {
  const OnboardingSaving(super.page);
}

/// Completion has been persisted.
final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted(super.page);
}

/// Owns onboarding progress independently of presentation controllers.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._prefs) : super(const OnboardingReady(0));
  final SharedPreferences _prefs;
  void pageChanged(int page) {
    if (state is OnboardingSaving || state is OnboardingCompleted) return;
    emit(OnboardingReady(page.clamp(0, 2)));
  }

  Future<bool> complete() async {
    if (state is OnboardingSaving || state is OnboardingCompleted) return false;
    final page = state.page;
    emit(OnboardingSaving(page));
    try {
      final saved = await _prefs.setBool(AppConstants.prefOnboardingDone, true);
      if (isClosed) return false;
      if (!saved) {
        emit(OnboardingReady(page, error: true));
        return false;
      }
      emit(OnboardingCompleted(page));
      return true;
    } catch (_) {
      if (!isClosed) emit(OnboardingReady(page, error: true));
      return false;
    }
  }
}
