import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/core/constants/app_constants.dart';

void main() {
  group('LocaleCubit', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state is English locale', () {
      final cubit = LocaleCubit(prefs);
      expect(cubit.state.locale.languageCode, 'en');
    });

    test('setLocale switches to Arabic', () async {
      final cubit = LocaleCubit(prefs);
      await cubit.setLocale(const Locale('ar'));
      expect(cubit.state.locale.languageCode, 'ar');
    });

    test('setLocale persists selection to SharedPreferences', () async {
      final cubit = LocaleCubit(prefs);
      await cubit.setLocale(const Locale('ar'));
      expect(prefs.getString(AppConstants.prefLocale), 'ar');
    });

    test('setLocale back to English emits English state', () async {
      final cubit = LocaleCubit(prefs);
      await cubit.setLocale(const Locale('ar'));
      await cubit.setLocale(const Locale('en'));
      expect(cubit.state.locale.languageCode, 'en');
    });

    test('setLocale with same locale is a no-op', () async {
      final cubit = LocaleCubit(prefs);
      final statesBefore = cubit.state;
      await cubit.setLocale(const Locale('en'));
      expect(cubit.state, statesBefore);
    });

    test('loadSavedLocale restores Arabic from prefs', () async {
      await prefs.setString(AppConstants.prefLocale, 'ar');
      final cubit = LocaleCubit(prefs)..loadSavedLocale();
      expect(cubit.state.locale.languageCode, 'ar');
    });

    test('loadSavedLocale with no saved value keeps English default', () {
      final cubit = LocaleCubit(prefs)..loadSavedLocale();
      expect(cubit.state.locale.languageCode, 'en');
    });

    test('supportedLocales contains en and ar', () {
      expect(
        LocaleCubit.supportedLocales.map((l) => l.languageCode),
        containsAll(['en', 'ar']),
      );
    });

    test('LocaleState equality — same locale is equal', () {
      const a = LocaleState(Locale('en'));
      const b = LocaleState(Locale('en'));
      expect(a, equals(b));
    });

    test('LocaleState equality — different locales are not equal', () {
      const a = LocaleState(Locale('en'));
      const b = LocaleState(Locale('ar'));
      expect(a, isNot(equals(b)));
    });
  });
}
