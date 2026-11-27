import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/profile/presentation/cubit/account_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated responsive Settings & Security page for Flutter Web.
class WebSettingsPage extends StatefulWidget {
  const WebSettingsPage({super.key, this.cubit});

  final AccountCubit? cubit;

  @override
  State<WebSettingsPage> createState() => _WebSettingsPageState();
}

class _WebSettingsPageState extends State<WebSettingsPage> {
  late final AccountCubit _cubit;
  late final bool _ownsCubit;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? (sl<AccountCubit>()..load());
  }

  @override
  void dispose() {
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  Future<void> _showChangeEmailDialog() async {
    final l10n = AppLocalizations.of(context);
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changeEmail),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.changeEmailInfo),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: l10n.newEmail),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.currentPassword),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _cubit.email(emailCtrl.text.trim(), passCtrl.text);
    }
    emailCtrl.dispose();
    passCtrl.dispose();
  }

  Future<void> _showChangePasswordDialog() async {
    final l10n = AppLocalizations.of(context);
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changePassword),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.currentPassword),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.newPassword),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _cubit.password(currentCtrl.text, newCtrl.text);
    }
    currentCtrl.dispose();
    newCtrl.dispose();
  }

  Future<void> _showDeleteAccountDialog() async {
    final l10n = AppLocalizations.of(context);
    final passCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.deleteAccountWarning),
              const SizedBox(height: 14),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.currentPassword),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _cubit.delete(passCtrl.text);
    }
    passCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeCubit = context.watch<ThemeCubit>();
    final localeCubit = context.watch<LocaleCubit>();
    final isDark = themeCubit.state.mode == ThemeMode.dark;
    final isArabic = localeCubit.state.locale.languageCode == 'ar';

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AccountCubit, AccountState>(
        listener: (context, state) {
          if (state is AccountDeleted && sl.isRegistered<SessionCubit>()) {
            sl<SessionCubit>().signOut();
          }
        },
        child: SingleChildScrollView(
          child: WebPageContainer(
            maxWidth: WebBreakpoints.narrowContentMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebSectionHeader(
                  title: l10n.settings,
                  trailing: OutlinedButton.icon(
                    onPressed: () => context.go(RoutePaths.profile),
                    icon: const Icon(Icons.person_outline_rounded, size: 18),
                    label: Text(l10n.profile),
                  ),
                ),
                const SizedBox(height: 24),
                WebSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appearance,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        title: Text(isDark ? l10n.themeDark : l10n.themeLight),
                        trailing: Switch(
                          value: isDark,
                          onChanged: (v) => themeCubit.select(
                            v ? ThemeMode.dark : ThemeMode.light,
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.language_rounded),
                        title: Text(l10n.homeLanguage),
                        trailing: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'en',
                              label: Text(l10n.languageEnglish),
                            ),
                            ButtonSegment(
                              value: 'ar',
                              label: Text(l10n.languageArabic),
                            ),
                          ],
                          selected: {isArabic ? 'ar' : 'en'},
                          onSelectionChanged: (values) =>
                              localeCubit.setLocale(Locale(values.first)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                WebSurfaceCard(
                  child: BlocBuilder<AccountCubit, AccountState>(
                    builder: (context, state) {
                      final busy = state is AccountReady && state.busy;
                      final hasPassword =
                          state is AccountReady &&
                          state.profile.passwordProvider;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.accountSecurity,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (hasPassword) ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.email_outlined),
                              title: Text(l10n.changeEmail),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: busy ? null : _showChangeEmailDialog,
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.lock_outline_rounded),
                              title: Text(l10n.changePassword),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: busy ? null : _showChangePasswordDialog,
                            ),
                            const Divider(),
                          ],
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: theme.colorScheme.error,
                            ),
                            title: Text(
                              l10n.deleteAccount,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            onTap: busy ? null : _showDeleteAccountDialog,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (sl.isRegistered<SessionCubit>()) {
                        await sl<SessionCubit>().signOut();
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.homeLogout),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
