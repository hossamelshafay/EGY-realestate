import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/price_prediction/domain/entities/prediction.dart';
import 'package:egy/features/price_prediction/presentation/cubit/prediction_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated two-column Price Prediction page for Flutter Web.
class WebPredictionPage extends StatefulWidget {
  const WebPredictionPage({super.key});

  @override
  State<WebPredictionPage> createState() => _WebPredictionPageState();
}

class _WebPredictionPageState extends State<WebPredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final _sizeController = TextEditingController(text: '150');
  final _bedsController = TextEditingController(text: '3');
  final _bathsController = TextEditingController(text: '2');
  final _latController = TextEditingController(text: '30.0444');
  final _lngController = TextEditingController(text: '31.2357');

  @override
  void dispose() {
    _sizeController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  String? _validateRange(
    AppLocalizations l10n,
    String? raw,
    double min,
    double max,
  ) {
    final v = double.tryParse(raw?.trim() ?? '');
    if (v == null || !v.isFinite || v < min || v > max) {
      return l10n.aiRangeValidation;
    }
    return null;
  }

  void _submit(PredictionReady state) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = state.category ?? state.options.categories.firstOrNull;
    final propertyType =
        state.propertyType ?? state.options.propertyTypes.firstOrNull;
    if (category == null || propertyType == null) return;

    final input = PredictionInput(
      size: double.parse(_sizeController.text.trim()),
      bedrooms: double.parse(_bedsController.text.trim()),
      bathrooms: double.parse(_bathsController.text.trim()),
      latitude: double.parse(_latController.text.trim()),
      longitude: double.parse(_lngController.text.trim()),
      propertyType: propertyType,
      category: category,
    );
    if (!input.isValid) return;
    context.read<PredictionCubit>().predict(input);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    return SingleChildScrollView(
      child: WebPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebSectionHeader(
              title: l10n.pricePrediction,
              subtitle: l10n.aiPredictSubtitle,
            ),
            const SizedBox(height: 24),
            BlocBuilder<PredictionCubit, PredictionState>(
              builder: (context, state) {
                if (state is PredictionInitial || state is PredictionLoading) {
                  return const SkeletonShimmer(
                    child: SkeletonBox(
                      width: double.infinity,
                      height: 360,
                      radius: 16,
                    ),
                  );
                }
                if (state is PredictionError) {
                  return WebSurfaceCard(
                    child: Column(
                      children: [
                        Text(l10n.aiUnavailable),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.read<PredictionCubit>().load(),
                          child: Text(l10n.retryButton),
                        ),
                      ],
                    ),
                  );
                }

                final ready = state as PredictionReady;
                final selectedCategory =
                    ready.category ?? ready.options.categories.firstOrNull;
                final selectedType =
                    ready.propertyType ??
                    ready.options.propertyTypes.firstOrNull;

                final formCard = WebSurfaceCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.aiSpecifications,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: l10n.aiCategory,
                          ),
                          items: [
                            for (final c in ready.options.categories)
                              DropdownMenuItem(value: c, child: Text(c)),
                          ],
                          onChanged: ready.submitting
                              ? null
                              : (v) => context.read<PredictionCubit>().select(
                                  category: v,
                                ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: InputDecoration(
                            labelText: l10n.aiPropertyType,
                          ),
                          items: [
                            for (final t in ready.options.propertyTypes)
                              DropdownMenuItem(value: t, child: Text(t)),
                          ],
                          onChanged: ready.submitting
                              ? null
                              : (v) => context.read<PredictionCubit>().select(
                                  propertyType: v,
                                ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _sizeController,
                          enabled: !ready.submitting,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.aiSize),
                          validator: (v) => _validateRange(l10n, v, 20, 10000),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bedsController,
                                enabled: !ready.submitting,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.aiBedrooms,
                                ),
                                validator: (v) =>
                                    _validateRange(l10n, v, 0, 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _bathsController,
                                enabled: !ready.submitting,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.aiBathrooms,
                                ),
                                validator: (v) =>
                                    _validateRange(l10n, v, 0, 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latController,
                                enabled: !ready.submitting,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.aiLatitude,
                                ),
                                validator: (v) =>
                                    _validateRange(l10n, v, 22, 32),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _lngController,
                                enabled: !ready.submitting,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.aiLongitude,
                                ),
                                validator: (v) =>
                                    _validateRange(l10n, v, 24, 38),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.aiCoordinatesHelp,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (ready.failure != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            l10n.aiInvalidInput,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: ready.submitting
                                    ? null
                                    : () => _submit(ready),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: ready.submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.aiCalculate),
                              ),
                            ),
                            if (ready.result != null) ...[
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () =>
                                    context.read<PredictionCubit>().reset(),
                                child: Text(l10n.aiReset),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                final resultCard = _PredictionResultPanel(
                  prediction: ready.result,
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: formCard),
                      const SizedBox(width: 28),
                      Expanded(flex: 5, child: resultCard),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    formCard,
                    const SizedBox(height: 24),
                    resultCard,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionResultPanel extends StatelessWidget {
  const _PredictionResultPanel({this.prediction});

  final Prediction? prediction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0');

    if (prediction == null) {
      return WebSurfaceCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 36,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.aiEstimatedPrice,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aiPredictSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final result = prediction!;
    return WebSurfaceCard(
      color: isDark ? AppColors.darkSurface : AppColors.primaryNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aiEstimatedPrice,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${fmt.format(result.price.round())} ${result.currency}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fmt.format(result.low.round())} – ${fmt.format(result.high.round())} ${result.currency}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aiHeuristicRange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${fmt.format(result.meterPrice.round())} ${result.currency} / m²',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
