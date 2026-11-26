import 'package:egy/core/widgets/safe_animated_size.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
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
import '../widgets/auth_social_actions.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_language_selector.dart';
import '../widgets/auth_action_button.dart';
import '../widgets/auth_motion_scope.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/signup_avatar_step.dart';
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
  String? _avatar;
  int _registerStep = 0;
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
      _registerStep = 0;
      if (AuthMotionScope.read(context) != null ||
          MediaQuery.disableAnimationsOf(context)) {
        _transition.value = 1;
      } else {
        _transition.forward(from: 0);
      }
    }
  }

  void _google() {
    context.read<AuthCubit>().google(avatarId: _avatar);
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    switch (widget.mode) {
      case AuthPageMode.login:
        cubit.signIn(_email.text, _password.text);
      case AuthPageMode.register:
        setState(() {
          _avatar ??= AvatarCatalog.ids.first;
          _registerStep = 1;
        });
      case AuthPageMode.reset:
        cubit.resetPassword(_email.text);
    }
  }

  void _createAccount() {
    context.read<AuthCubit>().register(
      _name.text,
      _email.text,
      _password.text,
      avatarId: _avatar ?? AvatarCatalog.ids.first,
    );
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
        final isStep2 = register && _registerStep == 1;
        final reduced = MediaQuery.disableAnimationsOf(context);
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return PopScope(
          canPop: !isStep2 || loading,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && isStep2 && !loading) {
              setState(() => _registerStep = 0);
            }
          },
          child: AuthShell(
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
                    AuthMotionScope.read(context) != null || reduced ? 0 : 450,
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
                  child: AnimatedSwitcher(
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offset = isStep2
                          ? Offset(isRtl ? -0.08 : 0.08, 0)
                          : Offset(isRtl ? 0.08 : -0.08, 0);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(
                            begin: offset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: isStep2
                        ? SignupAvatarStep(
                            key: const ValueKey('register_step_2'),
                            selectedAvatar: _avatar ?? AvatarCatalog.ids.first,
                            loading: loading,
                            showInlineError: widget.onState != null,
                            onBack: () => setState(() => _registerStep = 0),
                            onSelect: (id) => setState(() => _avatar = id),
                            onCreateAccount: _createAccount,
                          )
                        : Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.onState != null)
                                  const AuthInlineError(),
                                if (register) ...[
                                  _field(
                                    TextFormField(
                                      key: const Key('auth_name'),
                                      controller: _name,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                      autofillHints: const [AutofillHints.name],
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: InputDecoration(
                                        labelText: l.fullName,
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v?.trim().isEmpty ?? true)
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: InputDecoration(
                                      labelText: l.email,
                                      prefixIcon: const Icon(
                                        Icons.mail_outline,
                                      ),
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
                                    label: register
                                        ? l.continueAction
                                        : reset
                                        ? l.sendReset
                                        : title,
                                    loading: loading,
                                    onPressed: _submit,
                                  ),
                                ),
                                if (!reset)
                                  AuthSocialActions(
                                    loading: loading,
                                    onGoogle: _google,
                                  ),
                                const SizedBox(height: 20),
                                AuthEntranceStage(
                                  stage: 9,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      if (!reset)
                                        Text(
                                          register
                                              ? l.haveAccount
                                              : l.noAccount,
                                        ),
                                      TextButton(
                                        onPressed: loading
                                            ? null
                                            : () => context.goNamed(
                                                register || reset
                                                    ? RouteNames.login
                                                    : RouteNames.register,
                                              ),
                                        child: Text(
                                          register || reset
                                              ? l.logIn
                                              : l.createAccount,
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
