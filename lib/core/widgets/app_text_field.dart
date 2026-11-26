import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Labelled text input field that wraps Flutter's [TextFormField].
///
/// The surrounding [InputDecorationTheme] defined in [AppTheme] is used for
/// colours and shapes, so this widget only sets per-instance properties.
///
/// Usage:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   label: 'Email',
///   hint: 'you@example.com',
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;

  /// Label text rendered above the field.
  final String label;

  /// Placeholder inside the field.
  final String? hint;

  /// Inline validation error shown below the field.
  final String? errorText;

  /// Leading icon inside the field (uses [AppColors.textTertiary] colour).
  final IconData? prefixIcon;

  /// Trailing widget (e.g., password visibility toggle).
  final Widget? suffix;

  /// When `true`, input is hidden — use for passwords.
  final bool obscureText;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          autofocus: autofocus,
          maxLines: maxLines,
          style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textTertiary)
                : null,
            suffix: suffix,
          ),
        ),
      ],
    );
  }
}
