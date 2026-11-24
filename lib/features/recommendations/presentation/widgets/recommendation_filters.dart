import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';
import 'package:egy/core/widgets/primary_button.dart';
import 'package:egy/features/properties/presentation/property_type_label.dart';
import '../../domain/entities/recommendation_search.dart';

/// Local editor for filters committed to the Cubit on Search.
class RecommendationFilters extends StatefulWidget {
  const RecommendationFilters({super.key, required this.onSearch});
  final ValueChanged<RecommendationQuery> onSearch;
  @override
  State<RecommendationFilters> createState() => _RecommendationFiltersState();
}

class _RecommendationFiltersState extends State<RecommendationFilters> {
  final _form = GlobalKey<FormState>();
  final _city = TextEditingController();
  final _min = TextEditingController(), _max = TextEditingController();
  String _category = 'all';
  String _type = 'all';
  @override
  void dispose() {
    for (final value in [_city, _min, _max]) {
      value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: const Key('recommendation_category'),
            initialValue: _category,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.aiCategory),
            items: ['all', 'buy', 'rent', 'commercial_buy', 'commercial_rent']
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(aiCategoryLabel(l, value)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              _category = value ?? 'all';
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('recommendation_city'),
            controller: _city,
            decoration: InputDecoration(labelText: l.aiCity),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('recommendation_type'),
            initialValue: _type,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.aiTypeOptional),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l.aiAll)),
              for (final code in propertyTypeCodes)
                DropdownMenuItem(
                  value: code,
                  child: Text(propertyTypeLabel(l, code)),
                ),
            ],
            onChanged: (value) => _type = value ?? 'all',
          ),
          const SizedBox(height: 16),
          for (final entry in [
            (l.aiMinimumPrice, _min),
            (l.aiMaximumPrice, _max),
          ]) ...[
            TextFormField(
              controller: entry.$2,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: entry.$1),
              validator: (text) {
                if ((text ?? '').trim().isEmpty) {
                  return null;
                }
                final value = aiNumber(text!);
                if (value == null || value < 0) {
                  return l.aiRangeValidation;
                }
                final min = aiNumber(_min.text), max = aiNumber(_max.text);
                return min != null && max != null && min > max
                    ? l.aiInvalidInput
                    : null;
              },
            ),
            const SizedBox(height: 16),
          ],
          PrimaryButton(
            key: const Key('recommendation_search'),
            label: l.search,
            onPressed: () {
              if (!_form.currentState!.validate()) {
                return;
              }
              FocusScope.of(context).unfocus();
              widget.onSearch(
                RecommendationQuery(
                  category: _category,
                  city: _city.text.trim().isEmpty ? 'all' : _city.text.trim(),
                  propertyType: _type,
                  minPrice: aiNumber(_min.text),
                  maxPrice: aiNumber(_max.text),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
