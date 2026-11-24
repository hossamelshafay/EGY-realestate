import 'package:egy/core/widgets/safe_animated_size.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/session_page.dart';
import 'package:egy/core/widgets/session_morph_scope.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_style.dart';
import '../widgets/google_logo.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_language_selector.dart';
import '../widgets/auth_action_button.dart';
import '../widgets/auth_motion_scope.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_password_field.dart';
import 'auth_page_mode.dart';

export 'auth_page_mode.dart';

/// A stable router page owns one Cubit and one form throughout auth navigation.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.mode, this.onState});
  final AuthPageMode mode;
  final ValueChanged<AuthState>? onState;
  @override
  Widget build(BuildContext context) {
    if (SessionMorphScope.of(context) == null) {
      return SessionPage(authMode: mode);
    }
    return AuthEntrance(
      child: AuthStyle(
        child: BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: _AuthForm(mode: mode, onState: onState),
        ),
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.mode, this.onState});
  final AuthPageMode mode;
  final ValueChanged<AuthState>? onState;
  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm>
    with SingleTickerProviderStateMixin {
  late final AuthCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<AuthCubit>();
    _cubit.attachFeedback(widget.onState != null);
  }

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;
  late final AnimationController _transition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: 1,
  );
  @override
  void dispose() {
    _cubit.attachFeedback(false);
    _transition.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AuthForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      // Preserve all entered fields while the shared shell folds between intents.
      _hidePassword = true;
      _hideConfirm = true;
      if (AuthMotionScope.read(context) != null ||
          MediaQuery.disableAnimationsOf(context)) {
        _transition.value = 1;
      } else {
        _transition.forward(from: 0);
      }
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    switch (widget.mode) {
      case AuthPageMode.login:
        cubit.signIn(_email.text, _password.text);
      case AuthPageMode.register:
        cubit.register(_name.text, _email.text, _password.text);
      case AuthPageMode.reset:
        cubit.resetPassword(_email.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final register = widget.mode == AuthPageMode.register;
    final reset = widget.mode == AuthPageMode.reset;
    final title = reset
        ? l.resetTitle
        : register
        ? l.createAccount
        : l.logIn;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        widget.onState?.call(state);
        if ((state is AuthError && widget.onState == null) ||
            state is AuthResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is AuthError
                    ? authErrorMessage(l, state.code)
                    : l.resetSent,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return AuthShell(
          title: title,
          subtitle: reset
              ? l.authResetDescription
              : register
              ? l.authJoin
              : l.authWelcome,
          compact: register,
          child: SafeAnimatedSize(
            duration: Duration(
              milliseconds:
                  AuthMotionScope.read(context) != null ||
                      MediaQuery.disableAnimationsOf(context)
                  ? 0
                  : 450,
            ),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _transition,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, .025), end: Offset.zero)
                    .animate(
                      CurvedAnimation(
                        parent: _transition,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.onState != null) const AuthInlineError(),
                      if (register) ...[
                        _field(
                          TextFormField(
                            key: const Key('auth_name'),
                            controller: _name,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textPrimary),
                            autofillHints: const [AutofillHints.name],
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: l.fullName,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? l.requiredField
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _field(
                        TextFormField(
                          key: const Key('auth_email'),
                          controller: _email,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textPrimary),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: l.email,
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                          validator: (v) =>
                              !RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(v?.trim() ?? '')
                              ? l.invalidEmail
                              : null,
                        ),
                      ),
                      if (!reset) ...[
                        const SizedBox(height: 16),
                        _passwordField(false),
                        if (register) ...[
                          const SizedBox(height: 16),
                          _passwordField(true),
                        ],
                      ],
                      if (!register && !reset)
                        AuthEntranceStage(
                          exitOnHome: true,
                          stage: 7,
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: loading
                                  ? null
                                  : () => context.goNamed(
                                      RouteNames.forgotPassword,
                                    ),
                              child: Text(l.forgotPassword),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      AuthEntranceStage(
                        stage: 7,
                        child: AuthActionButton(
                          label: reset ? l.sendReset : title,
                          loading: loading,
                          onPressed: _submit,
                        ),
                      ),
                      if (!reset) ...[
                        const SizedBox(height: 24),
                        AuthEntranceStage(
                          stage: 7,
                          child: Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  l.orContinue,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthEntranceStage(
                          stage: 8,
                          child: OutlinedButton.icon(
                            key: const Key('auth_google'),
                            onPressed: loading
                                ? null
                                : () => context.read<AuthCubit>().google(),
                            icon: const GoogleLogo(),
                            label: Text(l.continueGoogle),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      AuthEntranceStage(
                        stage: 9,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (!reset)
                              Text(register ? l.haveAccount : l.noAccount),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () => context.goNamed(
                                      register || reset
                                          ? RouteNames.login
                                          : RouteNames.register,
                                    ),
                              child: Text(
                                register || reset ? l.logIn : l.createAccount,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!reset) ...[
                        const SizedBox(height: 12),
                        const AuthEntranceStage(
                          stage: 9,
                          child: AuthLanguageSelector(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(Widget child, {String? name}) {
    final key = name == null ? child.key : Key(name);
    return AuthEntranceStage(
      stage: key == const Key('auth_name')
          ? 3
          : key == const Key('auth_email')
          ? 4
          : key == const Key('auth_confirm_password')
          ? 6
          : 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withValues(alpha: .06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AuthFeedbackField(fieldKey: key, child: child),
      ),
    );
  }

  Widget _passwordField(bool confirm) => _field(
    AuthPasswordField(
      controller: confirm ? _confirm : _password,
      password: _password,
      confirm: confirm,
      register: widget.mode != AuthPageMode.login,
      hidden: confirm ? _hideConfirm : _hidePassword,
      onToggle: () => setState(() {
        if (confirm) {
          _hideConfirm = !_hideConfirm;
        } else {
          _hidePassword = !_hidePassword;
        }
      }),
    ),
    name: confirm ? 'auth_confirm_password' : 'auth_password',
  );
}
