import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/features/authentication/presentation/pages/auth_page.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_shell_motion.dart';
import 'package:egy/features/authentication/presentation/widgets/asymmetric_auth_clipper.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_header.dart';

void main() {
  test(
    'SLATE valley sweeps upward and registration is its exact horizontal mirror',
    () {
      const login = AsymmetricAuthClipper(
        mirror: 0,
        fold: 0,
        expansion: 0,
        home: 0,
      );
      const register = AsymmetricAuthClipper(
        mirror: 1,
        fold: 0,
        expansion: 0,
        home: 0,
      );
      for (var i = 0; i < 7; i++) {
        expect(
          register.points[i].dx,
          closeTo(1 - login.points[6 - i].dx, .00001),
        );
        expect(register.points[i].dy, closeTo(login.points[6 - i].dy, .00001));
      }
      final path = login.getClip(const Size(360, 240));
      expect(path.contains(const Offset(1, 150)), isTrue);
      expect(path.contains(const Offset(359, 150)), isFalse);
      expect(path.contains(const Offset(180, 215)), isTrue);
      final full = const AsymmetricAuthClipper(
        mirror: 0,
        fold: 0,
        expansion: 1,
        home: 0,
      ).getClip(const Size(360, 240));
      expect(full.contains(const Offset(359, 239)), isTrue);
      final home = const AsymmetricAuthClipper(
        mirror: 1,
        fold: 0,
        expansion: 1,
        home: 1,
      ).getClip(const Size(360, 240));
      final approved = const BrandHeaderClipper(
        32,
        shape: BrandHeaderShape.convex,
      ).getClip(const Size(360, 240));
      for (var x = 1.0; x < 360; x += 13) {
        for (var y = 1.0; y < 240; y += 11) {
          expect(home.contains(Offset(x, y)), approved.contains(Offset(x, y)));
        }
      }
    },
  );

  test(
    'Reset restores the old symmetric inward corners without changing Home',
    () {
      const size = Size(360, 260);
      final reset = const AsymmetricAuthClipper(
        mirror: 0,
        fold: 0,
        expansion: 0,
        home: 0,
        reset: 1,
      ).getClip(size);
      final approved = const BrandHeaderClipper(32).getClip(size);
      for (var x = 1.0; x < 360; x += 9) {
        for (var y = 1.0; y < 260; y += 7) {
          expect(reset.contains(Offset(x, y)), approved.contains(Offset(x, y)));
          expect(
            reset.contains(Offset(x, y)),
            reset.contains(Offset(360 - x, y)),
          );
        }
      }
    },
  );

  testWidgets(
    'stale failure playback cannot finish a newer successful attempt',
    (tester) async {
      var completed = 0;
      await tester.pumpWidget(const SizedBox.shrink());
      final motion = AuthShellMotion(
        vsync: tester,
        initialMode: AuthPageMode.login,
        initiallyHome: false,
        onSuccessReady: () => completed++,
      )..reduced = true;
      addTearDown(motion.dispose);
      await motion.showFailure('invalid-credential', 1);
      motion.playResult(const Duration(seconds: 2));
      // Success arrives before the failure player's post-frame start callback.
      await motion.showSuccess();
      await tester.pump();
      expect(motion.phase, AuthMotionPhase.successResult);
      expect(motion.result.value, 0);
      expect(completed, 0);
      motion.playResult(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump();
      expect(motion.phase, AuthMotionPhase.awaitingHome);
      motion.shake.stop();
      expect(completed, 1);
      
    },
  );

  testWidgets('result and shake ticks do not invalidate shell geometry', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    final motion = AuthShellMotion(
      vsync: tester,
      initialMode: AuthPageMode.login,
      initiallyHome: false,
      onSuccessReady: () {},
    );
      addTearDown(motion.dispose);
    final expanding = motion.showSuccess();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 521));
    await expanding;
    var layouts = 0;
    motion.addListener(() => layouts++);
    motion.playResult(const Duration(milliseconds: 1000));
    await tester.pump();
      await tester.pump();
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(motion.result.value, greaterThan(0));
    expect(layouts, 0);
    motion.shake.forward(from: 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(layouts, 0);
    motion.result.value = 1;
    expect(layouts, 1);
    expect(motion.phase, AuthMotionPhase.awaitingHome);
      motion.shake.stop();
    
  });

  testWidgets(
    'one 750ms clock contracts, swaps the form invisibly and unfolds',
    (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final motion = AuthShellMotion(
        vsync: tester,
        initialMode: AuthPageMode.login,
        initiallyHome: false,
        onSuccessReady: () {},
      );
      addTearDown(motion.dispose);
      final fold = motion.switchTo(AuthPageMode.register);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 375));
      expect(motion.fold, closeTo(.9985950670631749, .00001));
      expect(motion.formOpacity, closeTo(0, .001));
      expect(motion.mirror, closeTo(Curves.easeInOutCubic.transform(.5), .001));
      expect(motion.visibleMode, AuthPageMode.register);
      await tester.pump(const Duration(milliseconds: 376));
      await fold;
      expect(motion.mirror, 1);
      expect(motion.fold, 0);
      expect(motion.formOpacity, 1);
      
    },
  );

  testWidgets(
    'first failure returns, later failure shakes, later success still plays in full',
    (tester) async {
      var completed = 0;
      await tester.pumpWidget(const SizedBox.shrink());
      final motion = AuthShellMotion(
        vsync: tester,
        initialMode: AuthPageMode.login,
        initiallyHome: false,
        onSuccessReady: () => completed++,
      );
      addTearDown(motion.dispose);
      final first = motion.showFailure('invalid-credential', 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      await first;
      expect(motion.phase, AuthMotionPhase.failureResult);
      expect(motion.cover.value, 1);
      expect(motion.inlineReady, isFalse);
      motion.playResult(const Duration(milliseconds: 2002));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2003));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      await tester.pumpAndSettle();
      expect(motion.phase, AuthMotionPhase.idle);
      expect(motion.inlineReady, isTrue);
      await motion.showFailure('invalid-credential', 2);
      expect(motion.cover.value, 0);
      expect(motion.shake.isAnimating, isTrue);
      final success = motion.showSuccess();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 521));
      await success;
      expect(motion.phase, AuthMotionPhase.successResult);
      expect(motion.cover.value, 1);
      expect(completed, 0);
      motion.playResult(const Duration(milliseconds: 2625));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2624));
      expect(completed, 0);
      await tester.pump(const Duration(milliseconds: 2));
      expect(completed, 1);
      expect(motion.phase, AuthMotionPhase.awaitingHome);
      motion.shake.stop();
      expect(motion.cover.value, 1);
      motion.revealHome();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 901));
      expect(motion.home.value, 1);
      expect(completed, 1);
      
    },
  );

  testWidgets(
    'reduced motion settles an active cover without stranding its phase',
    (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final motion = AuthShellMotion(
        vsync: tester,
        initialMode: AuthPageMode.login,
        initiallyHome: false,
        onSuccessReady: () {},
      );
      addTearDown(motion.dispose);
      final transition = motion.showSuccess();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      motion.settleReducedMotion();
      await transition;
      expect(motion.phase, AuthMotionPhase.successResult);
      expect(motion.cover.value, 1);
      motion.playResult(const Duration(milliseconds: 2625));
      await tester.pump();
      await tester.pump();
      motion.revealHome();
      expect(motion.home.value, 1);
      expect(tester.hasRunningAnimations, isFalse);
      
    },
  );
}




