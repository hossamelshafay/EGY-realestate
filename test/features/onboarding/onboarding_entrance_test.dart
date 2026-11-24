import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/features/onboarding/presentation/widgets/onboarding_entrance.dart';

void main() {
  Widget scene({
    bool enabled = true,
    bool reduced = false,
    String label = 'EN',
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: OnboardingEntrance(
        enabled: enabled,
        child: Column(
          children: [
            for (var stage = 0; stage < 4; stage++)
              OnboardingEntranceStage(
                stage: stage,
                child: Text('$label $stage', key: Key('stage_$stage')),
              ),
          ],
        ),
      ),
    ),
  );

  double opacity(WidgetTester tester, int stage) => tester
      .widget<Opacity>(
        find
            .ancestor(
              of: find.byKey(Key('stage_$stage')),
              matching: find.byType(Opacity),
            )
            .first,
      )
      .opacity;

  testWidgets('entrance staggers and does not restart on content rebuild', (
    tester,
  ) async {
    await tester.pumpWidget(scene());
    expect(opacity(tester, 0), 0);
    await tester.pump(); // Start the ticker scheduled after the initial frame.
    await tester.pump(const Duration(milliseconds: 250));
    expect(opacity(tester, 0), greaterThan(0));
    expect(opacity(tester, 1), 0);
    expect(opacity(tester, 3), 0);
    await tester.pump(const Duration(milliseconds: 850));
    for (var i = 0; i < 4; i++) {
      expect(opacity(tester, i), 1);
    }
    await tester.pumpWidget(scene(label: 'AR'));
    expect(opacity(tester, 0), 1);
    expect(opacity(tester, 3), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct entry is settled immediately', (tester) async {
    await tester.pumpWidget(scene(enabled: false));
    expect(opacity(tester, 0), 1);
    expect(opacity(tester, 3), 1);
  });

  testWidgets('reduced motion skips the entire stagger', (tester) async {
    await tester.pumpWidget(scene(reduced: true));
    expect(opacity(tester, 0), 1);
    expect(opacity(tester, 3), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
