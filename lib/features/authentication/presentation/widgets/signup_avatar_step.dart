import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'auth_action_button.dart';
import 'auth_feedback.dart';

/// Step 2 of registration: large preview, 6-avatar responsive grid, and Create Account CTA.
class SignupAvatarStep extends StatelessWidget {
  const SignupAvatarStep({
    super.key,
    required this.selectedAvatar,
    required this.loading,
    required this.showInlineError,
    required this.onBack,
    required this.onSelect,
    required this.onCreateAccount,
  });

  final String selectedAvatar;
  final bool loading;
  final bool showInlineError;
  final VoidCallback onBack;
  final ValueChanged<String> onSelect;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduced = MediaQuery.disableAnimationsOf(context);

    return Column(
      key: const Key('signup_step_2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('signup_back'),
              tooltip: l.back,
              onPressed: loading ? null : onBack,
              icon: const BackButtonIcon(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l.signupStepProgress,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.primaryGold : AppColors.primaryNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (showInlineError) const AuthInlineError(),
        Text(
          l.chooseAvatarTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l.chooseAvatarSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(
                    alpha: isDark ? 0.24 : 0.16,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: reduced
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: ProfileAvatar(
                key: ValueKey('preview_$selectedAvatar'),
                avatarId: selectedAvatar,
                size: 92,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 250 ? 2 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AvatarCatalog.ids.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final id = AvatarCatalog.ids[index];
                final selected = id == selectedAvatar;
                final label = index < 3
                    ? l.avatarMasculine(index + 1)
                    : l.avatarFeminine(index - 2);
                return Semantics(
                  button: true,
                  selected: selected,
                  label: label,
                  child: InkWell(
                    key: ValueKey('avatar_$id'),
                    borderRadius: BorderRadius.circular(20),
                    onTap: loading ? null : () => onSelect(id),
                    child: AnimatedScale(
                      scale: selected && !reduced ? 1.04 : 1.0,
                      duration: reduced
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: AnimatedContainer(
                        duration: reduced
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: selected
                              ? AppColors.primaryGold.withValues(
                                  alpha: isDark ? 0.16 : 0.10,
                                )
                              : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                          border: Border.all(
                            width: selected ? 2.2 : 1,
                            color: selected
                                ? AppColors.primaryGold
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.4,
                                  ),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: ProfileAvatar(avatarId: id, size: 60),
                            ),
                            if (selected)
                              PositionedDirectional(
                                top: 0,
                                end: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        AuthActionButton(
          label: l.createAccount,
          loading: loading,
          onPressed: onCreateAccount,
        ),
      ],
    );
  }
}
