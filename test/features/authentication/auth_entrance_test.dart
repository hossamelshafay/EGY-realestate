import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_entrance.dart';

void main() {
  Widget scene({bool reduced = false, String label = 'EN'}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: AuthEntrance(
        child: Column(
          children: [
            for (var stage = 0; stage <= 6; stage++)
              AuthEntranceStage(stage: stage, child: Text('$label $stage')),
          ],
        ),
      ),
    ),
  );
  double opacity(WidgetTester tester, int stage) => tester
      .widget<Opacity>(find.byKey(ValueKey('auth_entrance_$stage')))
      .opacity;

  testWidgets(
    'initial mount reveals branding before fields and survives rebuilds',
    (tester) async {
      await tester.pumpWidget(scene());
      expect(opacity(tester, 0), 0);
      expect(opacity(tester, 4), 0);
      await tester.pump(const Duration(milliseconds: 200));
      final beforeRebuild = opacity(tester, 0);
      expect(beforeRebuild, greaterThan(0));
      expect(opacity(tester, 4), 0);
      await tester.pumpWidget(scene(label: 'AR'));
      expect(opacity(tester, 0), beforeRebuild);
      await tester.pump(const Duration(milliseconds: 350));
      expect(opacity(tester, 4), greaterThan(0));
      expect(opacity(tester, 5), 0);
      await tester.pumpAndSettle();
      for (var stage = 0; stage <= 6; stage++) {
        expect(opacity(tester, stage), 1);
      }
    },
  );
  testWidgets('reduced motion exposes all auth content immediately', (
    tester,
  ) async {
    await tester.pumpWidget(scene(reduced: true));
    for (var stage = 0; stage <= 6; stage++) {
      expect(opacity(tester, stage), 1);
    }
    expect(tester.hasRunningAnimations, isFalse);
  });
}
