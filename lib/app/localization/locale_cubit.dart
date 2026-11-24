import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// Immutable state holding the active [locale].
final class LocaleState extends Equatable {
  const LocaleState(this.locale);

  final Locale locale;

  @override
  List<Object> get props => [locale];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

/// Manages the application locale and persists the user's preference.
///
/// The cubit reads the saved locale from [SharedPreferences] on initialisation
/// and exposes [setLocale] to change and persist it at runtime.
///
/// Supported locales: English (`en`) and Arabic (`ar`).
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._prefs) : super(const LocaleState(Locale('en')));

  final SharedPreferences _prefs;

  static const _supportedLocales = [Locale('en'), Locale('ar')];

  /// Supported locales forwarded to [MaterialApp].
  static List<Locale> get supportedLocales => _supportedLocales;

  /// Loads the previously saved locale.  Call once during app startup.
  void loadSavedLocale() {
    final code = _prefs.getString(AppConstants.prefLocale);
    if (code != null) {
      final saved = _supportedLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => const Locale('en'),
      );
      emit(LocaleState(saved));
    }
  }

  /// Switches the locale and persists the selection.
  Future<void> setLocale(Locale locale) async {
    if (locale == state.locale) return;
    await _prefs.setString(AppConstants.prefLocale, locale.languageCode);
    emit(LocaleState(locale));
  }
}
