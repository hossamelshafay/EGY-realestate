import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../../domain/entities/prediction.dart';

/// Shows verified estimates and labels the range as heuristic.
class PredictionResult extends StatelessWidget {
  const PredictionResult({super.key, required this.result});
  final Prediction result;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    );
    return Card(
      key: const Key('prediction_result'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l.aiEstimatedPrice,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              number.format(result.price),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryGold,
              ),
            ),
            Text(result.currency == 'EGP/month' ? l.aiMonthly : l.aiCurrency),
            const SizedBox(height: 16),
            Text(l.aiHeuristicRange, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '${number.format(result.low)} – ${number.format(result.high)}',
            ),
          ],
        ),
      ),
    );
  }
}
