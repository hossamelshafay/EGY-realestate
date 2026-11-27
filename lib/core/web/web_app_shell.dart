import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'web_breakpoints.dart';
import 'web_theme.dart';

/// Dedicated responsive desktop shell for Flutter Web.
///
/// Replaces the mobile drawer and curved headers with a clean horizontal top
/// navigation bar on wide screens and a responsive drawer on narrow viewports.
class WebAppShell extends StatelessWidget {
  const WebAppShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_WebNavItem>[
      _WebNavItem(
        label: l10n.home,
        path: RoutePaths.home,
        icon: Icons.home_outlined,
      ),
      _WebNavItem(
        label: l10n.search,
        path: RoutePaths.propertyCatalog,
        icon: Icons.search_rounded,
      ),
      _WebNavItem(
        label: l10n.recommendations,
        path: RoutePaths.recommendations,
        icon: Icons.auto_awesome_outlined,
      ),
      _WebNavItem(
        label: l10n.pricePrediction,
        path: RoutePaths.pricePrediction,
        icon: Icons.analytics_outlined,
      ),
      _WebNavItem(
        label: l10n.aiChat,
        path: RoutePaths.aiChat,
        icon: Icons.chat_bubble_outline_rounded,
      ),
      _WebNavItem(
        label: l10n.favorites,
        path: RoutePaths.favorites,
        icon: Icons.favorite_border_rounded,
      ),
    ];

    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = WebBreakpoints.isExpanded(width);
    final theme = Theme.of(context);
    final webTheme = theme.brightness == Brightness.dark
        ? WebTheme.dark(theme)
        : WebTheme.light(theme);

    return Theme(
      data: webTheme,
      child: Scaffold(
        drawer: isDesktop
            ? null
            : _WebResponsiveDrawer(items: items, currentPath: currentPath),
        body: Column(
          children: [
            _WebTopNavBar(
              items: items,
              currentPath: currentPath,
              isDesktop: isDesktop,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _WebNavItem {
  const _WebNavItem({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}

class _WebTopNavBar extends StatelessWidget {
  const _WebTopNavBar({
    required this.items,
    required this.currentPath,
    required this.isDesktop,
  });

  final List<_WebNavItem> items;
  final String currentPath;
  final bool isDesktop;

  bool _isSelected(String itemPath) {
    if (itemPath == RoutePaths.home) {
      return currentPath == RoutePaths.home;
    }
    return currentPath.startsWith(itemPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.select<SessionCubit, dynamic>((c) => c.state.user);

    return Material(
      color: isDark ? WebPalette.darkCard : WebPalette.lightCard,
      elevation: 0,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 10,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: WebBreakpoints.contentMaxWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showBrandName = constraints.maxWidth >= 520;
                return Row(
                  children: [
                    if (!isDesktop)
                      Builder(
                        builder: (ctx) => IconButton(
                          tooltip: l10n.homeMenu,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    InkWell(
                      onTap: () => context.go(RoutePaths.home),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: Image.asset(
                                'assets/img/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (showBrandName) ...[
                              const SizedBox(width: 10),
                              Text(
                                l10n.appName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final item in items) ...[
                                _NavLinkButton(
                                  label: item.label,
                                  selected: _isSelected(item.path),
                                  onTap: () => context.go(item.path),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    _ThemeToggleButton(),
                    _LocaleToggleButton(),
                    const SizedBox(width: 4),
                    _AccountMenuButton(
                      avatarId: user?.avatarId as String?,
                      displayName: user?.name as String?,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLinkButton extends StatelessWidget {
  const _NavLinkButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryGold : AppColors.primaryNavy;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? activeColor : inactiveColor,
        backgroundColor: selected
            ? activeColor.withValues(alpha: isDark ? 0.14 : 0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.watch<ThemeCubit>();
    final isDark = cubit.state.mode == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? l10n.themeLight : l10n.themeDark,
      onPressed: () =>
          cubit.select(isDark ? ThemeMode.light : ThemeMode.dark),
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      ),
    );
  }
}

class _LocaleToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.watch<LocaleCubit>();
    final isArabic = cubit.state.locale.languageCode == 'ar';
    return TextButton(
      onPressed: () => cubit.setLocale(Locale(isArabic ? 'en' : 'ar')),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 38),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        isArabic ? l10n.languageEnglish : l10n.languageArabic,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AccountMenuButton extends StatelessWidget {
  const _AccountMenuButton({this.avatarId, this.displayName});

  final String? avatarId;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: l10n.profile,
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            context.go(RoutePaths.profile);
          case 'settings':
            context.go(RoutePaths.settings);
          case 'logout':
            if (sl.isRegistered<SessionCubit>()) {
              await sl<SessionCubit>().signOut();
            }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 20),
              const SizedBox(width: 10),
              Text(l10n.profile),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 10),
              Text(l10n.settings),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.homeLogout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileAvatar(avatarId: avatarId, size: 28),
            if (displayName != null &&
                displayName!.trim().isNotEmpty &&
                WebBreakpoints.isExpanded(
                  MediaQuery.sizeOf(context).width,
                )) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  displayName!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _WebResponsiveDrawer extends StatelessWidget {
  const _WebResponsiveDrawer({
    required this.items,
    required this.currentPath,
  });

  final List<_WebNavItem> items;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset('assets/img/logo.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in items)
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      selected: item.path == RoutePaths.home
                          ? currentPath == RoutePaths.home
                          : currentPath.startsWith(item.path),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.path);
                      },
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(l10n.profile),
                    selected: currentPath.startsWith(RoutePaths.profile),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.profile);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l10n.settings),
                    selected: currentPath.startsWith(RoutePaths.settings),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.settings);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                l10n.homeLogout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                if (sl.isRegistered<SessionCubit>()) {
                  await sl<SessionCubit>().signOut();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
