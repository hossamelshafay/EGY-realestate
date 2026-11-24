import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy/app/router/app_motion.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/features/onboarding/presentation/widgets/onboarding_entrance.dart';
import 'package:egy/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets(
    'reduced motion completes splash handoff without a lost event or stagger',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      Duration? entranceDuration;
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SplashPageWrapper()),
          GoRoute(
            name: RouteNames.onboarding,
            path: '/onboarding',
            pageBuilder: (context, state) {
              final page = AppMotion.page(
                context: context,
                key: state.pageKey,
                child: const OnboardingEntrance(
                  enabled: true,
                  child: OnboardingEntranceStage(
                    stage: 3,
                    child: Text('settled'),
                  ),
                ),
              );
              entranceDuration = page.transitionDuration;
              return page;
            },
          ),
        ],
      );
      await tester.pumpWidget(
        RepositoryProvider<SharedPreferences>.value(
          value: prefs,
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('settled'), findsOneWidget);
      expect(find.byType(SplashPage), findsNothing);
      expect(entranceDuration, Duration.zero);
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    },
  );
}
