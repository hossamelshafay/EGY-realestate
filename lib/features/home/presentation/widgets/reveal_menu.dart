part of 'drawer_scaffold.dart';

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.state, required this.session});
  final SessionState state;
  final SessionCubit session;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: AppColors.transparent,
      child: SafeArea(
        child: ListView(
          key: const Key('reveal_menu'),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(avatarId: state.user?.avatarId, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    state.user?.name?.trim().isNotEmpty == true
                        ? state.user!.name!
                        : l.homeWelcome,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (state.user?.email != null)
                    Text(
                      state.user!.email!,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            _item(context, Icons.home_outlined, l.home, RouteNames.home),
            _item(context, Icons.person_outline, l.profile, RouteNames.profile),
            _item(
              context,
              Icons.auto_awesome_outlined,
              l.recommendations,
              RouteNames.recommendations,
            ),
            _item(
              context,
              Icons.insights_rounded,
              l.pricePrediction,
              RouteNames.pricePrediction,
            ),
            _item(
              context,
              Icons.chat_bubble_outline_rounded,
              l.aiChat,
              RouteNames.aiChat,
            ),
            _item(
              context,
              Icons.favorite_border_rounded,
              l.favorites,
              RouteNames.favorites,
            ),
            _item(
              context,
              Icons.settings_outlined,
              l.settings,
              RouteNames.settings,
            ),
            Divider(
              color: AppColors.transparent,
            ),
            const Center(child: ThemeSelector(onNavy: true)),
            Divider(
              indent: 16,
              endIndent: 16,
              color: AppColors.white.withValues(alpha: .22),
            ),
            ListTile(
              textColor: AppColors.white,
              title: Text(l.homeLanguage),
              trailing: LocaleSelector(
                compact: true,
                onNavy: true,
                onSelected: (locale) => RevealNavigation.close(
                  context,
                  onClosed: () {
                    if (context.mounted) {
                      context.read<LocaleCubit>().setLocale(locale);
                    }
                  },
                ),
              ),
            ),
            ListTile(
              key: const Key('home_logout'),
              enabled: !state.signingOut,
              leading: const Icon(
                Icons.logout_rounded,
                color: AppColors.primaryGold,
              ),
              textColor: AppColors.white,
              title: Text(state.signingOut ? l.loading : l.homeLogout),
              onTap: session.signOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final router = GoRouter.of(context);
    final active = router.state.name == route;
    return ListTile(
      key: ValueKey('reveal_$route'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selected: active,
      selectedColor: AppColors.primaryGold,
      selectedTileColor: AppColors.primaryGold.withValues(alpha: .14),
      textColor: AppColors.white,
      iconColor: AppColors.white,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => RevealNavigation.close(
        context,
        onClosed: () {
          if (!context.mounted || session.state.user == null || active) return;
          if (route == RouteNames.home) {
            router.goNamed(route);
          } else {
            router.pushNamed<void>(route);
          }
        },
      ),
    );
  }
}
