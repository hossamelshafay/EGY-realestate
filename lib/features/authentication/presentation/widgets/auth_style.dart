import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egy/app/theme/app_colors.dart';

/// Typography and input styling scoped to authentication.
class AuthStyle extends StatelessWidget {
  const AuthStyle({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderLight),
    );
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          fontFamily: Localizations.localeOf(context).languageCode == 'ar'
              ? GoogleFonts.cairo().fontFamily
              : GoogleFonts.lato().fontFamily,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          errorMaxLines: 3,
          labelStyle: theme.textTheme.bodyMedium,
          hintStyle: theme.textTheme.bodyMedium,
          filled: true,
          fillColor: AppColors.offWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(
              color: AppColors.primaryGold,
              width: 1.5,
            ),
          ),
          errorBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.destructiveRed),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: const BorderSide(
              color: AppColors.destructiveRed,
              width: 1.5,
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}
