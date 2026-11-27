import 'dart:io';

import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/localization/locale_cubit.dart';
import 'package:egy/app/theme/app_theme.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/web/web_theme.dart';
import 'package:egy/features/ai_chat/domain/entities/chat_reply.dart';
import 'package:egy/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:egy/features/ai_chat/web/pages/web_chat_page.dart';
import 'package:egy/features/ai_chat/web/widgets/web_markdown_text.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class _FakeChatRepository implements ChatRepository {
  @override
  Future<ChatReply> send(String message, {String? sessionId}) async {
    return ChatReply(
      reply:
          '**Top Recommendations**\n\n- **New Cairo Villa** in Fifth Settlement\n- *Modern Apartment* in Zayed\n\n1. Compare prices\n2. Visit [EGY](https://egy.example.com)',
      sessionId: sessionId ?? 's1',
      properties: const [
        PropertyListing(
          id: 101,
          title: 'Luxury Villa in New Cairo with Garden',
          category: 'buy',
          propertyType: 'Villa',
          location: 'New Cairo, Fifth Settlement',
          price: 12500000,
          size: 320,
          bedrooms: 4,
          bathrooms: 3,
        ),
      ],
      suggestions: const ['Show similar villas', 'Filter under 10M'],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'WebChatPage renders Markdown and recommendation cards without overflow',
    (tester) async {
      final cubit = ChatCubit(_FakeChatRepository());
      addTearDown(cubit.close);

      for (final size in const [Size(375, 812), Size(1280, 800)]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              theme: WebTheme.light(AppTheme.light),
              localizationsDelegates: AppLocalizationConfig.delegates,
              supportedLocales: LocaleCubit.supportedLocales,
              home: const Scaffold(body: WebChatPage()),
            ),
          ),
        );
        await tester.pump();

        if (size.width == 375) {
          await tester.enterText(find.byType(TextField), 'Show villas');
          await tester.tap(find.byIcon(Icons.send_rounded));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(WebMarkdownText), findsOneWidget);
        expect(find.byType(WebPropertyCard), findsOneWidget);
        expect(find.text('Top Recommendations'), findsOneWidget);
        expect(find.textContaining('**Top Recommendations**'), findsNothing);
        expect(find.text('Show similar villas'), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('WebMarkdownText handles Arabic RTL and bold spans safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WebTheme.dark(AppTheme.dark),
        home: const Scaffold(
          body: WebMarkdownText(
            text: '**فيلا للبيع** في التجمع الخامس\n- مساحة *320* متر',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(WebMarkdownText), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
  });

  test('Web favicon and manifest are configured with EGY Development branding', () {
    final indexHtml = File('web/index.html').readAsStringSync();
    final manifest = File('web/manifest.json').readAsStringSync();
    expect(indexHtml, contains('<title>EGY Development</title>'));
    expect(indexHtml, contains('favicon.png'));
    expect(manifest, contains('"name": "EGY Development"'));
    expect(manifest, contains('#031A2D'));
    expect(File('web/favicon.png').existsSync(), isTrue);
    expect(File('web/icons/Icon-192.png').existsSync(), isTrue);
    expect(File('web/icons/Icon-512.png').existsSync(), isTrue);
  });
}
