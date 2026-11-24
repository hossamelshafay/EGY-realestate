import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';
import 'app_header.dart';
import 'rounded_content_panel.dart';

/// Full-screen scaffold that follows the navy-header + white-panel pattern.
///
/// ```
/// ┌─────────────────────────────────────┐
/// │          NAVY HEADER                │  ← [AppHeader]
/// │    Back Button    Title    Action   │
/// ├────────────────────────────────────┐│
/// │  ╭──────────────────────────────╮  ││  ← [RoundedContentPanel]
/// │  │   Scrollable content area    │  ││
/// │  └──────────────────────────────┘  ││
/// └─────────────────────────────────────┘
/// ```
///
/// For the Home screen, pass [showDrawerToggle] `true` and supply
/// [onDrawerToggle] to wire up the navigation drawer.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.onDrawerToggle,
    this.headerAction,
    this.showDrawerToggle = false,
  });

  /// Screen title shown in the navy header.
  final String title;

  /// Content rendered inside the white rounded panel.
  final Widget body;

  /// If provided, renders a back-arrow on the leading side.
  final VoidCallback? onBack;

  /// Called when the drawer hamburger icon is tapped.
  final VoidCallback? onDrawerToggle;

  /// Optional trailing action in the header.
  final Widget? headerAction;

  /// Show drawer hamburger instead of back arrow.
  final bool showDrawerToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: title,
              onBack: onBack,
              onDrawerToggle: onDrawerToggle,
              action: headerAction,
              showDrawerToggle: showDrawerToggle,
            ),
            RoundedContentPanel(child: body),
          ],
        ),
      ),
    );
  }
}
