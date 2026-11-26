import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/primary_button.dart';
import 'package:egy/core/widgets/ai/ai_labels.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/properties/presentation/property_type_label.dart';
import '../../domain/entities/prediction.dart';
import '../cubit/prediction_cubit.dart';
import 'prediction_result.dart';

/// Text controllers are local; selections and requests belong to Cubit.
class PredictionForm extends StatefulWidget {
  const PredictionForm({super.key, required this.state});
  final PredictionReady state;
  @override
  State<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  var _form = GlobalKey<FormState>();
  final _values = List.generate(5, (_) => TextEditingController());
  @override
  void dispose() {
    for (final value in _values) {
      value.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<PredictionCubit>().predict(
      PredictionInput(
        size: aiNumber(_values[0].text)!,
        bedrooms: aiNumber(_values[1].text)!,
        bathrooms: aiNumber(_values[2].text)!,
        latitude: aiNumber(_values[3].text)!,
        longitude: aiNumber(_values[4].text)!,
        category: widget.state.category!,
        propertyType: widget.state.propertyType!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), state = widget.state;
    final cubit = context.read<PredictionCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.aiSpecifications,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              key: const Key('prediction_category'),
              initialValue: state.category,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.aiCategory),
              items: state.options.categories
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(aiCategoryLabel(l, value), softWrap: true),
                    ),
                  )
                  .toList(),
              onChanged: state.submitting
                  ? null
                  : (value) => cubit.select(category: value),
              validator: (value) => value == null ? l.requiredField : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('prediction_type'),
              initialValue: state.propertyType,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.aiPropertyType),
              items: state.options.propertyTypes
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(propertyTypeLabel(l, value)),
                    ),
                  )
                  .toList(),
              onChanged: state.submitting
                  ? null
                  : (value) => cubit.select(propertyType: value),
              validator: (value) => value == null ? l.requiredField : null,
            ),
            const SizedBox(height: 16),
            _number(0, l.aiSize, 20, 10000),
            _number(1, l.aiBedrooms, 0, 20),
            _number(2, l.aiBathrooms, 0, 20),
            Text(
              l.aiCoordinatesHelp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _number(3, l.aiLatitude, 22, 32),
            _number(4, l.aiLongitude, 24, 38),
            if (state.failure != null) AiFeedback(failure: state.failure!),
            PrimaryButton(
              key: const Key('prediction_submit'),
              label: l.aiCalculate,
              isLoading: state.submitting,
              onPressed: _submit,
            ),
            if (state.submitting) const SkeletonPredictionResult(),
            if (!state.submitting && state.result != null) ...[
              const SizedBox(height: 24),
              PredictionResult(result: state.result!),
              TextButton(
                key: const Key('prediction_reset'),
                onPressed: () {
                  for (final value in _values) {
                    value.clear();
                  }
                  setState(() {
                    _form = GlobalKey<FormState>();
                  });
                  cubit.reset();
                },
                child: Text(l.aiReset),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _number(int index, String label, double min, double max) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey('prediction_number_$index'),
      controller: _values[index],
      enabled: !widget.state.submitting,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (text) {
        final value = aiNumber(text ?? '');
        return value == null || value < min || value > max
            ? AppLocalizations.of(context).aiRangeValidation
            : null;
      },
    ),
  );
}
