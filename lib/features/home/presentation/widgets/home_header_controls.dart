import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/app/theme/theme_selector.dart';

/// Equal side gutters keep the greeting centered in either reading direction.
class HomeHeaderControls extends StatelessWidget {
  const HomeHeaderControls({
    super.key,
    required this.greeting,
    required this.onMenu,
  });
  final String greeting;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Text(
                  greeting,
                  key: const Key('home_greeting'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
                ),
              ),
              const PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ThemeSelector(compact: true, onNavy: true),
                ),
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    key: const Key('home_menu'),
                    tooltip: l.homeMenu,
                    onPressed: onMenu,
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.homeMember,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
