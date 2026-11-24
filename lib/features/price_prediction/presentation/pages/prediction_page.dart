import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/content_fade.dart';
import '../cubit/prediction_cubit.dart';
import '../widgets/prediction_form.dart';

/// Real model options, explicit inputs and the backend's prediction result.
class PredictionPage extends StatelessWidget {
  const PredictionPage({super.key});
  @override
  Widget build(BuildContext context) => AuthenticatedScaffold(
    title: AppLocalizations.of(context).pricePrediction,
    subtitle: AppLocalizations.of(context).aiPredictSubtitle,
    child: BlocBuilder<PredictionCubit, PredictionState>(
      builder: (context, state) => ContentFade(
        child: KeyedSubtree(
          key: ValueKey(state.runtimeType),
          child: switch (state) {
            PredictionReady() => PredictionForm(state: state),
            PredictionError(:final failure) => AiFeedback(
              failure: failure,
              onRetry: context.read<PredictionCubit>().load,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    ),
  );
}
