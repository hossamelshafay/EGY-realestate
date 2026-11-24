import 'package:egy/app/localization/generated/app_localizations.dart';

/// User-facing translations for API category codes.
String aiCategoryLabel(AppLocalizations l, String value) => switch (value) {
  'buy' => l.homeResidentialSale,
  'rent' => l.homeResidentialRent,
  'commercial_buy' => l.homeCommercialSale,
  'commercial_rent' => l.homeCommercialRent,
  _ => l.aiAll,
};

/// Parses either Arabic or Latin digits without guessing missing model inputs.
double? aiNumber(String value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var normalized = value.trim().replaceAll('٫', '.');
  for (var i = 0; i < 10; i++) {
    normalized = normalized
        .replaceAll(arabic[i], '$i')
        .replaceAll(persian[i], '$i');
  }
  final number = double.tryParse(normalized);
  return number != null && number.isFinite ? number : null;
}
