import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/errors/failures.dart';
import 'package:egy/features/ai_chat/domain/entities/chat_reply.dart';
import 'package:egy/features/price_prediction/presentation/cubit/prediction_cubit.dart';
import 'package:egy/features/price_prediction/presentation/pages/prediction_page.dart';
import 'package:egy/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:egy/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:egy/features/ai_chat/presentation/pages/chat_page.dart';
import '../price_prediction/prediction_cubit_test.dart'
    show PendingRepository, result;
import 'cubits_test.dart' show CatalogFake, ChatFake;

Widget scene(Widget child, String code) => MaterialApp(
  theme: AppTheme.light,
  locale: Locale(code),
  localizationsDelegates: AppLocalizationConfig.delegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: const TextScaler.linear(1.3),
      disableAnimations: true,
    ),
    child: child!,
  ),
  home: child,
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets(
    'chat shows loading and failure, then resets without sending again',
    (tester) async {
      final pending = Completer<ChatReply>();
      final repository = ChatFake()..pending = pending;
      final cubit = ChatCubit(repository);
      final child = BlocProvider.value(value: cubit, child: const ChatPage());
      await tester.pumpWidget(scene(child, 'en'));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(ChatPage)));

      await tester.enterText(find.byKey(const Key('chat_input')), 'Hello');
      await tester.tap(find.byKey(const Key('chat_send')));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.completeError(const ServerFailure('offline', statusCode: 503));
      await tester.pumpAndSettle();
      expect(find.text(l.aiUnavailable), findsOneWidget);
      expect(find.text(l.retryButton), findsOneWidget);

      await tester.tap(find.byKey(const Key('chat_reset')));
      await tester.pumpAndSettle();
      expect(find.text(l.aiChatWelcome), findsOneWidget);
      expect(find.text(l.aiUnavailable), findsNothing);
      expect(repository.sessions, [null]);
      await tester.pumpWidget(const SizedBox.shrink());
      await cubit.close();
    },
  );
  testWidgets(
    'selected property type relabels immediately without changing the API code',
    (tester) async {
      final cubit = PredictionCubit(PendingRepository());
      await cubit.load();
      cubit.select(propertyType: 'Apartment');
      final child = BlocProvider.value(
        value: cubit,
        child: const PredictionPage(),
      );

      await tester.pumpWidget(scene(child, 'en'));
      await tester.pumpAndSettle();
      expect(find.text('Apartment'), findsOneWidget);

      await tester.pumpWidget(scene(child, 'ar'));
      await tester.pumpAndSettle();
      expect(find.text('شقة'), findsOneWidget);
      expect(find.text('Apartment'), findsNothing);
      expect((cubit.state as PredictionReady).propertyType, 'Apartment');

      await tester.pumpWidget(const SizedBox.shrink());
      await cubit.close();
    },
  );
  for (final code in ['en', 'ar']) {
    testWidgets(
      'prediction form validates, submits and shows actual result $code',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = PendingRepository(),
            cubit = PredictionCubit(PendingRepository());
        await cubit.close();
        final subject = PredictionCubit(repo);
        await subject.load();
        await tester.pumpWidget(
          scene(
            BlocProvider.value(value: subject, child: const PredictionPage()),
            code,
          ),
        );
        await tester.pumpAndSettle();
        for (final key in ['prediction_category', 'prediction_type']) {
          await tester.ensureVisible(find.byKey(Key(key)));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(Key(key)));
          await tester.pumpAndSettle();
          final l = AppLocalizations.of(
            tester.element(find.byType(PredictionPage)),
          );
          final option = key == 'prediction_category'
              ? l.homeResidentialSale
              : l.propertyTypeApartment;
          await tester.tap(find.text(option).hitTestable().first);
          await tester.pumpAndSettle();
        }
        final values = code == 'ar'
            ? [
                '\u0661\u0663\u0660',
                '\u0663',
                '\u0662',
                '\u0663\u0660\u066b\u0660\u0663',
                '\u0663\u0661\u066b\u0664\u0667',
              ]
            : ['130', '3', '2', '30.03', '31.47'];
        for (var i = 0; i < values.length; i++) {
          final field = find.byKey(ValueKey('prediction_number_$i'));
          await tester.ensureVisible(field);
          await tester.pumpAndSettle();
          await tester.enterText(field, values[i]);
        }
        await tester.ensureVisible(find.byKey(const Key('prediction_submit')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('prediction_submit')));
        await tester.pump();
        expect(repo.calls, 1);
        expect((subject.state as PredictionReady).propertyType, 'Apartment');
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        repo.pending.complete(result);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('prediction_result')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('prediction_result')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await subject.close();
      },
    );
    testWidgets('recommendations paginate real repository results $code', (
      tester,
    ) async {
      final cubit = RecommendationsCubit(CatalogFake());
      await cubit.search();
      await tester.pumpWidget(
        scene(
          BlocProvider.value(value: cubit, child: const RecommendationsPage()),
          code,
        ),
      );
      await tester.pumpAndSettle();
      final more = find.byKey(const Key('recommendation_more'));
      await tester.scrollUntilVisible(
        more,
        240,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('recommendation_list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect((cubit.state as RecommendationsReady).items, hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await cubit.close();
    });
    testWidgets(
      'chat opens without a request, sends and resets a session $code',
      (tester) async {
        final repo = ChatFake(), cubit = ChatCubit(ChatFake());
        await cubit.close();
        final subject = ChatCubit(repo);
        await tester.pumpWidget(
          scene(
            BlocProvider.value(value: subject, child: const ChatPage()),
            code,
          ),
        );
        await tester.pumpAndSettle();
        expect(repo.sessions, isEmpty);
        await tester.enterText(find.byKey(const Key('chat_input')), 'hello');
        await tester.tap(find.byKey(const Key('chat_send')));
        await tester.pumpAndSettle();
        expect(repo.sessions, [null]);
        tester.widget<ListView>(find.byType(ListView)).controller!.jumpTo(0);
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SelectableText &&
                widget.data == 'A real catalog result',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('listing_1')), findsOneWidget);
        await tester.tap(find.byKey(const Key('chat_reset')));
        await tester.pumpAndSettle();
        expect((subject.state as ChatReady).messages, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await subject.close();
      },
    );
  }
}
