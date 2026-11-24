import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/theme/app_colors.dart';

/// Compact locale controls preserve the current form and route.
class LocaleSelector extends StatelessWidget {
  const LocaleSelector({
    super.key,
    this.compact = false,
    this.onNavy = false,
    this.onSelected,
    this.keyPrefix = 'auth_language',
  });
  final bool compact;
  final bool onNavy;
  final ValueChanged<Locale>? onSelected;
  final String keyPrefix;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in ['en', 'ar']) ...[
            if (code == 'ar')
              const SizedBox(height: 16, child: VerticalDivider(width: 1)),
            TextButton(
              key: Key('${keyPrefix}_$code'),
              onPressed: () {
                final locale = Locale(code);
                final select = onSelected;
                if (select == null) {
                  context.read<LocaleCubit>().setLocale(locale);
                } else {
                  select(locale);
                }
              },
              style: TextButton.styleFrom(
                minimumSize: compact ? const Size(48, 48) : null,
                padding: compact
                    ? const EdgeInsets.symmetric(horizontal: 8)
                    : null,
                foregroundColor: current == code
                    ? AppColors.primaryGold
                    : onNavy
                    ? AppColors.white
                    : AppColors.textSecondary,
              ),
              child: Text(code == 'en' ? l.languageEnglish : l.languageArabic),
            ),
          ],
        ],
      ),
    );
  }
}
