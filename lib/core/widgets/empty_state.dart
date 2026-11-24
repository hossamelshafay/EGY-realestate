import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Generic empty-state view shown when a list or data set has no items.
///
/// Displays an [icon], a primary [title], an optional [subtitle], and an
/// optional [action] widget (e.g., a button to trigger a first action).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.action,
  });

  /// Icon rendered above the title. Defaults to [Icons.inbox_outlined].
  final IconData icon;

  /// Primary empty-state title (e.g., "No results found").
  final String title;

  /// Optional secondary message providing context or guidance.
  final String? subtitle;

  /// Optional action widget (e.g., a button to clear filters).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
