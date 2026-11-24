import 'package:material_ui/material_ui.dart';
import 'generated/app_localizations.dart';

/// Delegates must match the standalone Material widgets used by this app.
abstract final class AppLocalizationConfig {
  static const delegates = [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];
}
