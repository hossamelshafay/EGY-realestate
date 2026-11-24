import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/features/price_prediction/presentation/cubit/prediction_cubit.dart';
import 'package:egy/features/price_prediction/presentation/pages/prediction_page.dart';
import 'package:egy/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:egy/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:egy/features/ai_chat/presentation/pages/chat_page.dart';

/// Route-owned Cubits dispose sessions and pending screen work on navigation.
abstract final class AiDestination {
  static Widget prediction() => BlocProvider(
    create: (_) => sl<PredictionCubit>()..load(),
    child: const PredictionPage(),
  );
  static Widget recommendations({int? similarTo}) => BlocProvider(
    create: (_) {
      final cubit = sl<RecommendationsCubit>();
      if (similarTo == null) {
        cubit.search();
      } else {
        cubit.similar(similarTo);
      }
      return cubit;
    },
    child: RecommendationsPage(similarTo: similarTo),
  );
  static Widget chat() =>
      BlocProvider(create: (_) => sl<ChatCubit>(), child: const ChatPage());
}
