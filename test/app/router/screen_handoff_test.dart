import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/app/router/app_motion.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/onboarding/presentation/widgets/onboarding_entrance.dart';

void main() {
  testWidgets(
    'one progress updates outgoing pixels and incoming stagger together',
    (tester) async {
      final handoff = ScreenHandoff();
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              HandoffScope(
                handoff: handoff,
                incoming: false,
                child: const RouteMotionStage(
                  stage: 0,
                  child: Text('outgoing'),
                ),
              ),
              HandoffScope(
                handoff: handoff,
                incoming: true,
                child: const OnboardingEntrance(
                  enabled: true,
                  child: HandoffSurface(
                    color: AppColors.onboardingSurface,
                    child: Column(
                      children: [
                        OnboardingEntranceStage(
                          stage: 0,
                          child: Text('illustration'),
                        ),
                        OnboardingEntranceStage(stage: 1, child: Text('title')),
                        OnboardingEntranceStage(
                          stage: 2,
                          child: Text('description'),
                        ),
                        OnboardingEntranceStage(
                          stage: 3,
                          child: Text('controls'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      double opacity(String key) =>
          tester.widget<Opacity>(find.byKey(ValueKey(key))).opacity;
      expect(opacity('handoff_exit_0'), 1);
      expect(opacity('onboarding_entrance_0'), 0);
      expect(opacity('handoff_background'), 0);
      handoff.value = .25;
      await tester.pump();
      expect(opacity('handoff_exit_0'), inExclusiveRange(0, 1));
      expect(opacity('onboarding_entrance_0'), greaterThan(0));
      expect(opacity('onboarding_entrance_1'), 0);
      expect(opacity('handoff_background'), inExclusiveRange(0, 1));
      handoff.value = .45;
      await tester.pump();
      expect(opacity('handoff_exit_0'), 0);
      expect(opacity('onboarding_entrance_1'), greaterThan(0));
      expect(opacity('onboarding_entrance_2'), 0);
      handoff.value = 1;
      await tester.pump();
      for (var stage = 0; stage < 4; stage++) {
        expect(opacity('onboarding_entrance_$stage'), 1);
      }
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      handoff.dispose();
    },
  );
}
