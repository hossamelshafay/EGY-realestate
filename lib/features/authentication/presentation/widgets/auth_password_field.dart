import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';

/// Form controllers stay in the persistent form State across auth intent changes.
class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.password,
    required this.confirm,
    required this.register,
    required this.hidden,
    required this.onToggle,
  });
  final TextEditingController controller, password;
  final bool confirm, register, hidden;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextFormField(
      key: Key(confirm ? 'auth_confirm_password' : 'auth_password'),
      controller: controller,
      obscureText: hidden,
      textAlign: TextAlign.start,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      autofillHints: [
        register ? AutofillHints.newPassword : AutofillHints.password,
      ],
      decoration: InputDecoration(
        labelText: confirm ? l.confirmPassword : l.password,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: hidden ? l.showPassword : l.hidePassword,
          onPressed: onToggle,
          icon: Icon(
            hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: (v) {
        if (confirm) return v != password.text ? l.passwordMismatch : null;
        if ((v ?? '').isEmpty) return l.requiredField;
        if (register && v!.length < 8) return l.shortPassword;
        return null;
      },
    );
  }
}
