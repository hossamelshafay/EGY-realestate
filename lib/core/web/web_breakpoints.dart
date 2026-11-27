import 'package:material_ui/material_ui.dart';

import 'web_theme.dart';

/// Breakpoints and layout helpers for the dedicated Flutter Web experience.
abstract final class WebBreakpoints {
  static const double compactMax = 640;
  static const double mediumMax = 1024;
  static const double contentMaxWidth = 1280;
  static const double narrowContentMaxWidth = 960;
  static const double formMaxWidth = 480;

  static bool isCompact(double width) => width < compactMax;
  static bool isMedium(double width) =>
      width >= compactMax && width < mediumMax;
  static bool isExpanded(double width) => width >= mediumMax;

  static int gridColumns(
    double width, {
    int expanded = 3,
    int medium = 2,
    int compact = 1,
  }) {
    if (width >= mediumMax) return expanded;
    if (width >= compactMax) return medium;
    return compact;
  }

  static double horizontalPadding(double width) {
    if (width >= mediumMax) return 32;
    if (width >= compactMax) return 24;
    return 16;
  }
}

/// Centers Web page content within a readable desktop max width.
class WebPageContainer extends StatelessWidget {
  const WebPageContainer({
    super.key,
    required this.child,
    this.maxWidth = WebBreakpoints.contentMaxWidth,
    this.verticalPadding = 32,
  });

  final Widget child;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = WebBreakpoints.horizontalPadding(width);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Clean, flat-elevated surface card for Web sections and panels.
class WebSurfaceCard extends StatelessWidget {
  const WebSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 16,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:
            color ??
            (isDark ? WebPalette.darkCard : WebPalette.lightCard),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              borderColor ??
              (isDark ? WebPalette.darkBorder : WebPalette.lightBorder),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Consistent section heading for desktop Web pages.
class WebSectionHeader extends StatelessWidget {
  const WebSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}
