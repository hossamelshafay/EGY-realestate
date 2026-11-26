import 'dart:ui' as ui;

import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/orbiting_card_border.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final color in [AppColors.white, AppColors.primaryGold]) {
    testWidgets('rendered $color orbit covers all rounded corners and edges', (
      tester,
    ) async {
      await tester.runAsync(() async {
        const width = 220;
        const height = 140;
        const radius = 32.0;
        final outer = RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 220, 140),
          const Radius.circular(radius),
        );
        final visited = <String>{};
        for (var frame = 0; frame < 64; frame++) {
          final recorder = ui.PictureRecorder();
          OrbitingBorderPainter(
            progress: AlwaysStoppedAnimation(frame / 64),
            color: color,
            radius: radius,
          ).paint(Canvas(recorder), const Size(220, 140));
          final picture = recorder.endRecording();
          final image = await picture.toImage(width, height);
          final pixels = (await image.toByteData())!;
          var count = 0;
          var xSum = 0.0;
          var ySum = 0.0;
          for (var y = 0; y < height; y++) {
            for (var x = 0; x < width; x++) {
              final offset = (y * width + x) * 4;
              // Locate the luminous core rather than the softer trail and halo.
              if (pixels.getUint8(offset + 3) < 220) continue;
              count++;
              xSum += x + .5;
              ySum += y + .5;
            }
          }
          expect(count, greaterThan(0), reason: 'Visible core at frame $frame');
          final head = Offset(xSum / count, ySum / count);
          expect(outer.contains(head), isTrue);
          expect(
            outer.deflate(7).contains(head),
            isFalse,
            reason: 'Dot stays at perimeter at frame $frame',
          );
          final horizontal = head.dx < radius
              ? 'left'
              : head.dx > width - radius
              ? 'right'
              : 'center';
          final vertical = head.dy < radius
              ? 'top'
              : head.dy > height - radius
              ? 'bottom'
              : 'center';
          visited.add('$horizontal/$vertical');
          image.dispose();
          picture.dispose();
        }
        expect(
          visited,
          containsAll([
            'left/top',
            'right/top',
            'left/bottom',
            'right/bottom',
            'center/top',
            'center/bottom',
            'left/center',
            'right/center',
          ]),
        );
      });
    });
  }
}
