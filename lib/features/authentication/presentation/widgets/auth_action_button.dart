import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_colors.dart';

/// Gold gradient action with native button semantics and disabled behaviour.
class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: AppColors.goldGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryGold.withValues(alpha: .2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: FilledButton(
      key: const Key('auth_submit'),
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.white.withValues(alpha: 0),
        disabledBackgroundColor: AppColors.white.withValues(alpha: .25),
        foregroundColor: AppColors.white,
        shadowColor: AppColors.white.withValues(alpha: 0),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label),
    ),
  );
}
