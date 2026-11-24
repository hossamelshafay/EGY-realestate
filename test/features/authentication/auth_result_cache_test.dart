import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:egy/features/authentication/presentation/widgets/auth_result_cache.dart';

void main() {
  test(
    'prewarming shares each pending composition with all subsequent attempts',
    () {
      var loads = 0;
      final cache = AuthResultCache(
        load: (_) {
          loads++;
          return Completer<LottieComposition>().future;
        },
      );
      cache.warmup();
      final success = cache.composition(AuthResultCache.success);
      final failure = cache.composition(AuthResultCache.failure);
      cache.warmup();
      expect(cache.composition(AuthResultCache.success), same(success));
      expect(cache.composition(AuthResultCache.failure), same(failure));
      expect(loads, 2);
    },
  );

  test(
    'an unavailable composition can retry without poisoning later attempts',
    () async {
      var loads = 0;
      final cache = AuthResultCache(
        load: (_) {
          loads++;
          return Future<LottieComposition>.error(StateError('missing asset'));
        },
      );
      await expectLater(
        cache.composition(AuthResultCache.success),
        throwsStateError,
      );
      await expectLater(
        cache.composition(AuthResultCache.success),
        throwsStateError,
      );
      expect(loads, 2);
    },
  );
}
