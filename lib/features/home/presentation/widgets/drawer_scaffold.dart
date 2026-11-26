import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/theme_selector.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:egy/core/widgets/locale_selector.dart';
import 'package:egy/core/widgets/reveal_navigation.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';

part 'reveal_menu.dart';

/// Supplies the authenticated destinations to the reveal presentation.
class DrawerScaffold extends StatelessWidget {
  const DrawerScaffold({super.key, required this.child, required this.enabled});
  final Widget child;
  final bool enabled;

  static void open(BuildContext context) => RevealNavigation.open(context);

  @override
  Widget build(BuildContext context) {
    if (!sl.isRegistered<SessionCubit>()) {
      return Scaffold(backgroundColor: AppColors.transparent, body: child);
    }
    final session = sl<SessionCubit>();
    return BlocConsumer<SessionCubit, SessionState>(
      bloc: session,
      buildWhen: (before, after) =>
          before.user?.id != after.user?.id ||
          before.user?.name != after.user?.name ||
          before.user?.email != after.user?.email ||
          before.user?.avatarId != after.user?.avatarId ||
          before.signingOut != after.signingOut,
      listener: (context, state) {
        if (state.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).homeLogoutError),
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.transparent,
        body: RevealNavigation(
          menu: enabled && state.user != null
              ? _HomeDrawer(state: state, session: session)
              : null,
          child: child,
        ),
      ),
    );
  }
}
