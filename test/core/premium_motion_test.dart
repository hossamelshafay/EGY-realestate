import 'package:egy/app/router/app_motion.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/orbiting_card_border.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'route slides directionally and respects reduced motion $direction',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: direction,
              child: Builder(
                builder: (context) {
                  final page = AppMotion.authenticatedPage(
                    context: context,
                    key: const ValueKey('route'),
                    child: const Text('destination'),
                  );
                  expect(
                    page.transitionDuration,
                    const Duration(milliseconds: 500),
                  );
                  expect(
                    page.reverseTransitionDuration,
                    const Duration(milliseconds: 420),
                  );
                  return page.transitionsBuilder(
                    context,
                    const AlwaysStoppedAnimation(.5),
                    const AlwaysStoppedAnimation(0),
                    page.child,
                  );
                },
              ),
            ),
          ),
        );
        final slide = tester.widget<SlideTransition>(
          find.byKey(const Key('authenticated_route_slide')),
        );
        expect(
          slide.position.value.dx.sign,
          direction == TextDirection.rtl ? -1 : 1,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  final page = AppMotion.authenticatedPage(
                    context: context,
                    key: const ValueKey('reduced'),
                    child: const Text('reduced'),
                  );
                  expect(page.transitionDuration, Duration.zero);
                  return page.transitionsBuilder(
                    context,
                    const AlwaysStoppedAnimation(.5),
                    const AlwaysStoppedAnimation(0),
                    page.child,
                  );
                },
              ),
            ),
          ),
        );
        expect(
          find.byKey(const Key('authenticated_route_slide')),
          findsNothing,
        );
      },
    );
  }

  for (final color in [AppColors.white, AppColors.primaryGold]) {
    testWidgets(
      'border remains interactive and stops for reduced motion $color',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Center(
                child: OrbitingCardBorder(
                  color: color,
                  radius: 24,
                  child: SizedBox(
                    width: 240,
                    height: 160,
                    child: TextButton(
                      onPressed: () => taps++,
                      child: const Text('card'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('card'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('off-screen cards stop scheduling frames', (tester) async {
    final scroll = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: ListView(
          controller: scroll,
          children: const [
            OrbitingCardBorder(
              color: AppColors.white,
              child: SizedBox(height: 160),
            ),
            SizedBox(height: 2400),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    scroll.jumpTo(1000);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
    scroll.dispose();
  });
}
