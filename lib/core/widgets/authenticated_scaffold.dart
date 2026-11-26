import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'brand_curve_surface.dart';

import 'reveal_navigation.dart';

/// Shared toolbar, concave navy header, and content surface for internal routes.
class AuthenticatedScaffold extends StatelessWidget {
  const AuthenticatedScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canReveal = RevealNavigation.availableOf(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: BrandCurveSurface(
              clipKey: const Key('authenticated_header'),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.navyGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: kToolbarHeight,
                        child: AppBar(
                          primary: false,
                          centerTitle: false,
                          backgroundColor: AppColors.transparent,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          leading: IconButton(
                            tooltip: l.back,
                            icon: const BackButtonIcon(),
                            onPressed: () {
                              final router = GoRouter.maybeOf(context);
                              if (router == null) {
                                Navigator.maybePop(context);
                              } else if (router.canPop()) {
                                router.pop();
                              } else {
                                router.goNamed(RouteNames.home);
                              }
                            },
                          ),
                          title: Text(title, overflow: TextOverflow.ellipsis),
                          actions: [
                            ...?actions,
                            if (canReveal)
                              IconButton(
                                key: const Key('authenticated_reveal'),
                                tooltip: l.homeMenu,
                                onPressed: () => RevealNavigation.open(context),
                                icon: const Icon(Icons.menu_rounded),
                              ),
                          ],
                        ),
                      ),
                      if (subtitle case final description?)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            24,
                            8,
                            24,
                            12,
                          ),
                          child: Text(
                            description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
