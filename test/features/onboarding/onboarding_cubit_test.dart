import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/core/constants/app_constants.dart';
import 'package:egy/features/onboarding/presentation/cubit/onboarding_cubit.dart';

void main() {
  test('progress is bounded and completion preserves locale', () async {
    SharedPreferences.setMockInitialValues({AppConstants.prefLocale: 'ar'});
    final prefs = await SharedPreferences.getInstance();
    final cubit = OnboardingCubit(prefs);
    cubit.pageChanged(99);
    expect(cubit.state.page, 2);
    expect(prefs.getBool(AppConstants.prefOnboardingDone), isNull);
    expect(await cubit.complete(), isTrue);
    expect(prefs.getBool(AppConstants.prefOnboardingDone), isTrue);
    expect(prefs.getString(AppConstants.prefLocale), 'ar');
    await cubit.close();
  });
}
