import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import 'auth_motion_scope.dart';
import 'auth_result_cache.dart';

/// Result ticks repaint only this bounded layer, never the shell's layout.
class AuthResultAnimation extends StatelessWidget {
  const AuthResultAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    final motion = AuthMotionScope.read(context)!;
    if (motion.reduced) {
      motion.playResult(Duration.zero);
      return const SizedBox.shrink();
    }
    final asset = motion.successfulResult
        ? AuthResultCache.success
        : AuthResultCache.failure;
    Widget player(LottieComposition composition) {
      motion.playResult(composition.duration);
      return Lottie(composition: composition, key: ValueKey(asset),
        controller: motion.result, repeat: false, frameRate: FrameRate.composition);
    }
    final cached = AuthResultCache.instance.ready(asset);
    return Center(
      child: RepaintBoundary(
        child: SizedBox(
          width: 220,
          height: 220,
          child: cached != null ? player(cached) : FutureBuilder<LottieComposition>(
            key: ValueKey('composition:$asset'),
            future: AuthResultCache.instance.composition(asset),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                motion.resultUnavailable();
                return const SizedBox.shrink();
              }
              final composition = snapshot.data;
              if (composition == null) return const SizedBox.shrink();
              return player(composition);
            },
          ),
        ),
      ),
    );
  }
}
