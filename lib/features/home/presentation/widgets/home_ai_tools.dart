import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:egy/app/router/route_names.dart';
import 'home_circle_action.dart';
import 'home_palette.dart';

/// The reference's two compact tools; each action is explicitly a future feature.
class HomeAiTools extends StatelessWidget {
  const HomeAiTools({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.homeAiTools,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: HomePalette.ink(context)),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _tool(
                  context,
                  'home_tool_price',
                  Icons.insights_rounded,
                  l.homePredictorTitle,
                  l.homePriceDescription,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tool(
                  context,
                  'home_tool_recommendations',
                  Icons.star_border_rounded,
                  l.recommendations,
                  l.homeHybridDescription,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tool(
    BuildContext context,
    String key,
    IconData icon,
    String title,
    String description,
  ) => Material(
    key: ValueKey(key),
    color: HomePalette.surface(context),
    elevation: HomePalette.dark(context) ? 0 : 2,
    shadowColor: AppColors.primaryNavy.withValues(alpha: .1),
    borderRadius: BorderRadius.circular(24),
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.pushNamed(
        key == 'home_tool_price'
            ? RouteNames.pricePrediction
            : RouteNames.recommendations,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(icon, size: 36, color: AppColors.primaryGold),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HomePalette.ink(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomePalette.muted(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: HomeCircleAction(
                  label: title,
                  onPressed: () => context.pushNamed(
                    key == 'home_tool_price'
                        ? RouteNames.pricePrediction
                        : RouteNames.recommendations,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
