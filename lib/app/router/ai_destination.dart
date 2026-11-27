import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:egy/features/ai_chat/presentation/pages/chat_page.dart';
import 'package:egy/features/ai_chat/web/pages/web_chat_page.dart';
import 'package:egy/features/price_prediction/presentation/cubit/prediction_cubit.dart';
import 'package:egy/features/price_prediction/presentation/pages/prediction_page.dart';
import 'package:egy/features/price_prediction/web/pages/web_prediction_page.dart';
import 'package:egy/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:egy/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:egy/features/recommendations/web/pages/web_recommendations_page.dart';

/// Builds AI feature routes with the required Cubit lifecycle.
abstract final class AiDestination {
  static Widget prediction({bool isWeb = kIsWeb}) => BlocProvider(
    create: (_) => sl<PredictionCubit>()..load(),
    child: isWeb ? const WebPredictionPage() : const PredictionPage(),
  );
  static Widget recommendations({int? similarTo, bool isWeb = kIsWeb}) =>
      BlocProvider(
        create: (_) {
          final cubit = sl<RecommendationsCubit>();
          if (similarTo == null) {
            cubit.search();
          } else {
            cubit.similar(similarTo);
          }
          return cubit;
        },
        child: isWeb
            ? WebRecommendationsPage(similarTo: similarTo)
            : RecommendationsPage(similarTo: similarTo),
      );
  static Widget chat({bool isWeb = kIsWeb}) => BlocProvider.value(
    value: sl<ChatCubit>(),
    child: isWeb ? const WebChatPage() : const ChatPage(),
  );
}
