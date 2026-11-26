import 'package:egy/app/theme/theme_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/authentication/domain/entities/auth_user.dart';
import '../../support/session_repository.dart';

void main() {
  test('logout and login retain the device appearance preference', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appearance = ThemeCubit(prefs);
    await appearance.select(ThemeMode.dark);
    final repository = SessionTestRepository();
    repository.restore(
      const AuthUser(id: 'theme-user', email: 'test@example.com'),
    );
    final session = SessionCubit(repository);
    await session.signOut();
    expect(session.state.user, isNull);
    repository.restore(
      const AuthUser(id: 'theme-user', email: 'test@example.com'),
    );
    expect(session.state.user?.id, 'theme-user');
    expect(appearance.state.mode, ThemeMode.dark);
    expect(prefs.getString(ThemeCubit.preferenceKey), 'dark');
    await appearance.close();
    await session.close();
    await repository.dispose();
  });
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    test('restores $mode independently of session/login state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final first = ThemeCubit(prefs);
      expect(first.state.mode, ThemeMode.light);
      await first.select(mode);
      await first.close();
      final restored = ThemeCubit(prefs);
      expect(restored.state.mode, mode);
      await restored.close();
    });
  }
  test('invalid preference defaults safely to Light', () async {
    SharedPreferences.setMockInitialValues({
      ThemeCubit.preferenceKey: 'invalid',
    });
    final cubit = ThemeCubit(await SharedPreferences.getInstance());
    expect(cubit.state.mode, ThemeMode.light);
    await cubit.close();
  });
}
