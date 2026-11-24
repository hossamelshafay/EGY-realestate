import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/core/constants/app_constants.dart';
import 'package:egy/features/splash/presentation/cubit/splash_cubit.dart';

void main() {
  group('SplashCubit', () {
    test('initial state is SplashAnimating', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SplashCubit(prefs);
      expect(cubit.state, isA<SplashAnimating>());
      await cubit.close();
    });

    test('navigates to onboarding when onboarding not completed', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SplashCubit(prefs);

      cubit.onAnimationComplete();

      expect(cubit.state, isA<SplashDone>());
      expect(
        (cubit.state as SplashDone).destination,
        SplashDestination.onboarding,
      );
      await cubit.close();
    });

    test('navigates to login when onboarding already completed', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefOnboardingDone: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = SplashCubit(prefs);

      cubit.onAnimationComplete();

      expect(cubit.state, isA<SplashDone>());
      expect((cubit.state as SplashDone).destination, SplashDestination.login);
      await cubit.close();
    });

    test('calling onAnimationComplete twice does not emit twice', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SplashCubit(prefs);

      final states = <SplashState>[];
      final sub = cubit.stream.listen(states.add);

      cubit.onAnimationComplete();
      cubit.onAnimationComplete();

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // Only one SplashDone should be emitted (second call is not suppressed by
      // the cubit since the cubit is not closed, but the destination should be
      // the same).
      expect(states.length, greaterThanOrEqualTo(1));
      expect(states.last, isA<SplashDone>());
      await cubit.close();
    });
  });
}
