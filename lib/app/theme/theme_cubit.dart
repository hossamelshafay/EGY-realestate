import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local appearance preference, independent of authentication lifecycle.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this.preferences) : super(ThemeSelected(_restore(preferences))) {
    if (preferences.getString(preferenceKey) == 'system') {
      preferences.setString(preferenceKey, 'light');
    }
  }
  final SharedPreferences preferences;
  static const preferenceKey = 'appearance_mode';

  static ThemeMode _restore(SharedPreferences preferences) =>
      switch (preferences.getString(preferenceKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      };

  Future<void> select(ThemeMode mode) async {
    if (mode == ThemeMode.system) mode = ThemeMode.light;
    if (state.mode == mode) return;
    emit(ThemeSelected(mode));
    await preferences.setString(preferenceKey, mode.name);
  }
}

/// Immutable appearance state; independent of session and feature state.
sealed class ThemeState {
  const ThemeState(this.mode);
  final ThemeMode mode;
}

final class ThemeSelected extends ThemeState {
  const ThemeSelected(super.mode);
}
