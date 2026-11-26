import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../../domain/entities/avatar_catalog.dart';
import 'profile_avatar.dart';

/// Accessible required selection with stable IDs shared by Signup and Profile.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    this.value,
    required this.onChanged,
    this.formKey,
  });
  final String? value;
  final ValueChanged<String> onChanged;
  final GlobalKey<FormFieldState<String>>? formKey;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FormField<String>(
      key: formKey,
      initialValue: value,
      validator: (value) =>
          AvatarCatalog.valid(value) ? null : l.avatarRequired,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.chooseAvatar, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var index = 0; index < AvatarCatalog.ids.length; index++)
                Semantics(
                  button: true,
                  selected: field.value == AvatarCatalog.ids[index],
                  label: index < 3
                      ? l.avatarMasculine(index + 1)
                      : l.avatarFeminine(index - 2),
                  child: InkWell(
                    key: ValueKey('avatar_${AvatarCatalog.ids[index]}'),
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      field.didChange(AvatarCatalog.ids[index]);
                      onChanged(AvatarCatalog.ids[index]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: field.value == AvatarCatalog.ids[index]
                              ? AppColors.primaryGold
                              : AppColors.transparent,
                        ),
                      ),
                      child: ProfileAvatar(
                        avatarId: AvatarCatalog.ids[index],
                        size: 56,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (field.errorText case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
