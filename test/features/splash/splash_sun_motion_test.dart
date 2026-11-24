import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egy/features/splash/presentation/widgets/splash_sun_motion.dart';

void main() {
  test('sun crosses the fixed logo and leaves it fully revealed', () {
    const size = Size(224, 88);
    var previous = 0.0;
    for (var ms = 2200; ms <= 3500; ms += 25) {
      final reveal = SplashSunMotion.reveal(ms.toDouble());
      final clip = SunLogoClipper(reveal).getClip(size);
      expect(reveal, greaterThanOrEqualTo(previous));
      expect(clip.right, size.width);
      expect(clip.top, 0);
      expect(
        clip.left + 88,
        closeTo(
          (SplashSunMotion.center(ms.toDouble()).dx - 13).clamp(88, 312),
          .001,
        ),
      );
      previous = reveal;
    }
    expect(SplashSunMotion.reveal(2200), 0);
    expect(SplashSunMotion.reveal(3500), 1);
    expect(SplashSunMotion.reveal(4100), 1);
    expect(SunLogoClipper(1).getClip(size), Offset.zero & size);
  });
}
