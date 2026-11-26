import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import '../../domain/entities/account_profile.dart';
import '../cubit/account_cubit.dart';
import '../widgets/account_scope.dart';

enum AccountAction { email, password, delete }

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key, required this.action});
  final AccountAction action;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = switch (action) {
      AccountAction.email => l.changeEmail,
      AccountAction.password => l.changePassword,
      AccountAction.delete => l.deleteAccount,
    };
    return AccountScope(
      title: title,
      builder: (context, state) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _SecurityForm(
          action: action,
          profile: state.profile,
          busy: state.busy,
        ),
      ),
    );
  }
}

class _SecurityForm extends StatefulWidget {
  const _SecurityForm({
    required this.action,
    required this.profile,
    required this.busy,
  });
  final AccountAction action;
  final AccountProfile profile;
  final bool busy;
  @override
  State<_SecurityForm> createState() => _SecurityFormState();
}

class _SecurityFormState extends State<_SecurityForm> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _replacement = TextEditingController();
  final _confirm = TextEditingController();
  @override
  void dispose() {
    _current.dispose();
    _replacement.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final cubit = context.read<AccountCubit>();
    if (widget.action == AccountAction.delete) {
      final l = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.deleteAccount),
          content: Text(l.deleteAccountWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.deleteAccountConfirm),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      await cubit.delete(_current.text);
    } else if (widget.action == AccountAction.email) {
      await cubit.email(_replacement.text, _current.text);
    } else {
      await cubit.password(_current.text, _replacement.text);
    }
    if (!mounted) return;
    if (cubit.state case AccountReady(
      :final notice,
    ) when notice != null) {
      _current.clear();
      _confirm.clear();
      if (widget.action == AccountAction.password) _replacement.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final password = widget.action == AccountAction.password;
    if (password && !widget.profile.passwordProvider) {
      return Text(l.accountProviderManaged);
    }
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.action == AccountAction.email
                ? l.changeEmailInfo
                : widget.action == AccountAction.delete
                ? l.deleteAccountWarning
                : l.accountPasswordRules,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (widget.profile.passwordProvider)
            TextFormField(
              key: const Key('account_current_password'),
              controller: _current,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(labelText: l.currentPassword),
              validator: (value) =>
                  value == null || value.isEmpty ? l.requiredField : null,
            )
          else
            Text(l.googleReauth),
          if (widget.action != AccountAction.delete) ...[
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('account_replacement'),
              controller: _replacement,
              obscureText: password,
              autocorrect: false,
              enableSuggestions: !password,
              keyboardType: password
                  ? TextInputType.visiblePassword
                  : TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: password ? l.newPassword : l.newEmail,
              ),
              validator: (value) {
                if (password) {
                  return (value?.length ?? 0) < 8
                      ? l.accountPasswordRules
                      : null;
                }
                return RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(value?.trim() ?? '')
                    ? null
                    : l.invalidEmail;
              },
            ),
          ],
          if (password) ...[
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('account_confirm_password'),
              controller: _confirm,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(labelText: l.confirmPassword),
              validator: (value) =>
                  value != _replacement.text ? l.passwordMismatch : null,
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            key: const Key('account_submit'),
            onPressed: widget.busy ? null : _submit,
            style: widget.action == AccountAction.delete
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: widget.busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.action == AccountAction.delete
                        ? l.deleteAccount
                        : widget.action == AccountAction.email
                        ? l.sendVerification
                        : l.accountSave,
                  ),
          ),
        ],
      ),
    );
  }
}
