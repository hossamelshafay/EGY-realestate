import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/theme_selector.dart';
import 'package:egy/core/widgets/locale_selector.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import '../cubit/account_cubit.dart';
import '../widgets/account_scope.dart';
import '../widgets/profile_summary.dart';

/// Only functional account and device preferences are exposed.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AccountScope(
      title: l.settings,
      builder: (context, state) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.profile),
            child: ProfileSummary(profile: state.profile),
          ),
          const SizedBox(height: 24),
          _row(
            context,
            Icons.person_outline,
            l.editProfile,
            RouteNames.editProfile,
          ),
          const Divider(),
          _row(
            context,
            Icons.alternate_email,
            l.changeEmail,
            RouteNames.changeEmail,
          ),
          if (state.profile.passwordProvider)
            _row(
              context,
              Icons.lock_outline,
              l.changePassword,
              RouteNames.changePassword,
            ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language, color: AppColors.primaryGold),
            title: Text(l.homeLanguage),
            trailing: const LocaleSelector(compact: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.palette_outlined,
              color: AppColors.primaryGold,
            ),
            title: Text(l.appearance),
            trailing: const ThemeSelector(compact: true),
          ),
          const Divider(),
          ListTile(
            key: const Key('settings_logout'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: AppColors.primaryGold),
            title: Text(l.homeLogout),
            onTap: () async {
              final session = sl<SessionCubit>();
              await session.signOut();
              if (context.mounted && session.state.error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.homeLogoutError)));
              }
            },
          ),
          ListTile(
            key: const Key('settings_delete'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l.deleteAccount,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => context.pushNamed(RouteNames.deleteAccount),
          ),
          TextButton(
            onPressed: context.read<AccountCubit>().load,
            child: Text(l.refreshAccount),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: AppColors.primaryGold),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
      await context.pushNamed<Object?>(route);
      if (!context.mounted) return;
      context.read<AccountCubit>().load();
      if (sl.isRegistered<SessionCubit>()) {
        sl<SessionCubit>().refresh(force: true);
      }
    },
  );
}
