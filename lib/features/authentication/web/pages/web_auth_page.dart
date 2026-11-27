import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/web_split_auth_layout.dart';

enum WebAuthMode { login, register, forgotPassword }

/// Dedicated Flutter Web authentication page using a 50/50 split-screen layout.
class WebAuthPage extends StatefulWidget {
  const WebAuthPage({
    super.key,
    required this.mode,
    this.cubit,
  });

  final WebAuthMode mode;
  final AuthCubit? cubit;

  @override
  State<WebAuthPage> createState() => _WebAuthPageState();
}

class _WebAuthPageState extends State<WebAuthPage> {
  late final AuthCubit _cubit;
  late final bool _ownsCubit;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _registerStep = 0;
  String? _selectedAvatar = AvatarCatalog.ids.first;
  String? _avatarError;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = (widget.cubit ?? sl<AuthCubit>())..attachFeedback(false);
  }

  @override
  void didUpdateWidget(covariant WebAuthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _registerStep = 0;
      _avatarError = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  String _errorMessage(AppLocalizations l10n, String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' =>
      l10n.invalidCredentials,
    'email-already-in-use' => l10n.emailInUse,
    'network-request-failed' => l10n.authNetwork,
    'cancelled' => l10n.authCancelled,
    'profile-sync-incomplete' => l10n.authProfilePartial,
    _ => l10n.authGeneric,
  };

  String? _validateEmail(AppLocalizations l10n, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.requiredField;
    if (!v.contains('@') || !v.contains('.')) return l10n.invalidEmail;
    return null;
  }

  String? _validatePassword(AppLocalizations l10n, String? value) {
    final v = value ?? '';
    if (v.isEmpty) return l10n.requiredField;
    if (v.length < 8) return l10n.shortPassword;
    return null;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (widget.mode == WebAuthMode.register && _registerStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _registerStep = 1;
          _avatarError = null;
        });
      }
      return;
    }
    if (widget.mode == WebAuthMode.register && _registerStep == 1) {
      if (!AvatarCatalog.valid(_selectedAvatar)) {
        setState(() => _avatarError = l10n.avatarRequired);
        return;
      }
      _cubit.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        avatarId: _selectedAvatar,
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.mode == WebAuthMode.login) {
      _cubit.signIn(_emailController.text, _passwordController.text);
    } else if (widget.mode == WebAuthMode.forgotPassword) {
      _cubit.resetPassword(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: WebSplitAuthLayout(
        form: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final loading = state is AuthLoading;
            final errorText = state is AuthError
                ? _errorMessage(l10n, state.code)
                : null;
            final resetSent = state is AuthResetSent;

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    switch (widget.mode) {
                      WebAuthMode.login => l10n.logIn,
                      WebAuthMode.register => l10n.createAccount,
                      WebAuthMode.forgotPassword => l10n.resetTitle,
                    },
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    switch (widget.mode) {
                      WebAuthMode.login => l10n.authWelcome,
                      WebAuthMode.register =>
                        _registerStep == 0
                            ? l10n.authJoin
                            : l10n.chooseAvatarSubtitle,
                      WebAuthMode.forgotPassword => l10n.authResetDescription,
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (errorText != null) ...[
                    _AuthFeedbackBanner(
                      message: errorText,
                      isError: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (resetSent) ...[
                    _AuthFeedbackBanner(
                      message: l10n.resetSent,
                      isError: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.mode == WebAuthMode.register &&
                      _registerStep == 1) ...[
                    Text(
                      l10n.signupStepProgress,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AvatarPickerGrid(
                      selected: _selectedAvatar,
                      onSelect: (id) => setState(() {
                        _selectedAvatar = id;
                        _avatarError = null;
                      }),
                    ),
                    if (_avatarError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _avatarError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: loading
                              ? null
                              : () => setState(() => _registerStep = 0),
                          child: Text(l10n.back),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: loading ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.createAccount),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    if (widget.mode == WebAuthMode.register) ...[
                      TextFormField(
                        controller: _nameController,
                        enabled: !loading,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.requiredField
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      enabled: !loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: widget.mode == WebAuthMode.forgotPassword
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) => _validateEmail(l10n, v),
                      onFieldSubmitted:
                          widget.mode == WebAuthMode.forgotPassword
                          ? (_) => _submit()
                          : null,
                    ),
                    if (widget.mode != WebAuthMode.forgotPassword) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !loading,
                        obscureText: _obscurePassword,
                        textInputAction: widget.mode == WebAuthMode.register
                            ? TextInputAction.next
                            : TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) => _validatePassword(l10n, v),
                        onFieldSubmitted: widget.mode == WebAuthMode.login
                            ? (_) => _submit()
                            : null,
                      ),
                    ],
                    if (widget.mode == WebAuthMode.register) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        enabled: !loading,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscureConfirm
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.requiredField;
                          if (v != _passwordController.text) {
                            return l10n.passwordMismatch;
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                    if (widget.mode == WebAuthMode.login) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: loading
                              ? null
                              : () => context.go(RoutePaths.forgotPassword),
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 20),
                    FilledButton(
                      onPressed: loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(switch (widget.mode) {
                              WebAuthMode.login => l10n.logIn,
                              WebAuthMode.register => l10n.continueAction,
                              WebAuthMode.forgotPassword => l10n.sendReset,
                            }),
                    ),
                    if (widget.mode != WebAuthMode.forgotPassword) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.orContinue,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: loading ? null : () => _cubit.google(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                        label: Text(l10n.continueGoogle),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        widget.mode == WebAuthMode.login
                            ? l10n.noAccount
                            : l10n.haveAccount,
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => context.go(
                                widget.mode == WebAuthMode.login
                                    ? RoutePaths.register
                                    : RoutePaths.login,
                              ),
                        child: Text(
                          widget.mode == WebAuthMode.login
                              ? l10n.createAccount
                              : l10n.logIn,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthFeedbackBanner extends StatelessWidget {
  const _AuthFeedbackBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isError
        ? scheme.errorContainer
        : AppColors.primaryGold.withValues(alpha: 0.16);
    final fg = isError ? scheme.onErrorContainer : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError ? scheme.error : AppColors.primaryGold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPickerGrid extends StatelessWidget {
  const _AvatarPickerGrid({
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: [
        for (final id in AvatarCatalog.ids)
          InkWell(
            onTap: () => onSelect(id),
            borderRadius: BorderRadius.circular(40),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected == id
                      ? AppColors.primaryGold
                      : scheme.outlineVariant.withValues(alpha: 0.4),
                  width: selected == id ? 3 : 1,
                ),
              ),
              child: ProfileAvatar(avatarId: id, size: 64),
            ),
          ),
      ],
    );
  }
}
