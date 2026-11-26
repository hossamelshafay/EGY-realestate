import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/app/theme/theme_cubit.dart';
import 'package:egy/app/theme/theme_reveal.dart';
import 'package:egy/app/theme/theme_selector.dart';
import 'package:egy/features/properties/presentation/widgets/property_image_clipper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('clip reveals dark outward and contracts dark toward exact origin', () {
    const size = Size(400, 800);
    const origin = Offset(310, 60);
    expect(
      ThemeCircleClipper.coveringRadius(size, origin),
      greaterThan((const Offset(400, 800) - origin).distance),
    );
    final outward = const ThemeCircleClipper(
      origin: origin,
      progress: .4,
      darkToLight: false,
    ).getClip(size);
    expect(outward.contains(origin), isFalse);
    expect(outward.contains(const Offset(1, 799)), isTrue);
    final inward = const ThemeCircleClipper(
      origin: origin,
      progress: .6,
      darkToLight: true,
    ).getClip(size);
    expect(inward.contains(origin), isTrue);
    expect(inward.contains(const Offset(1, 799)), isFalse);
    final end = const ThemeCircleClipper(
      origin: origin,
      progress: 1,
      darkToLight: true,
    ).getClip(size);
    expect(end.contains(const Offset(310, 61)), isFalse);
  });
  test('details image has convex bottom and card endpoint stays rounded', () {
    const size = Size(360, 400);
    final image = const PropertyImageClipper(radius: 0, curve: 1).getClip(size);
    expect(image.contains(const Offset(180, 399)), isTrue);
    expect(image.contains(const Offset(1, 399)), isFalse);
    final card = const PropertyImageClipper(radius: 24, curve: 0).getClip(size);
    expect(card.contains(const Offset(1, 399)), isFalse);
    expect(card.contains(const Offset(180, 399)), isTrue);
  });
  for (final reduced in [true, false]) {
    testWidgets(
      'rapid theme changes preserve route and input, reduced=$reduced',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final cubit = ThemeCubit(await SharedPreferences.getInstance());
        final input = TextEditingController(text: 'retained draft');
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: Column(
                  children: [
                    const ThemeSelector(),
                    TextField(controller: input),
                    TextButton(
                      onPressed: () => context.push('/next'),
                      child: const Text('next'),
                    ),
                  ],
                ),
              ),
            ),
            GoRoute(
              path: '/next',
              builder: (_, _) => const Scaffold(body: Text('destination')),
            ),
          ],
        );
        addTearDown(() async {
          router.dispose();
          input.dispose();
          await cubit.close();
        });
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, mode) => MaterialApp.router(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: mode.mode,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizationConfig.delegates,
                supportedLocales: const [Locale('en'), Locale('ar')],
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: reduced),
                  child: ThemeReveal(router: router, child: child!),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fieldElement = tester.element(find.byType(TextField));
        await tester.tap(find.byKey(const ValueKey('theme_dark')));
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(cubit.state.mode, ThemeMode.dark);
        if (!reduced) {
          expect(
            find.byKey(const Key('theme_circular_reveal')),
            findsOneWidget,
          );
        }
        await tester.tap(find.byKey(const ValueKey('theme_light')));
        await tester.pump();
        // Navigation must cancel an in-flight overlay while preserving the chosen mode.
        router.push('/next');
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/next');
        router.pop();
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(TextField)), same(fieldElement));
        expect(input.text, 'retained draft');
        expect(cubit.state.mode, ThemeMode.light);
        await cubit.select(ThemeMode.system);
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.byType(TextField))).brightness,
          Brightness.light,
        );
        expect(tester.element(find.byType(TextField)), same(fieldElement));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
