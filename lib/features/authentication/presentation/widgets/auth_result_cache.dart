import 'dart:async';

import 'package:lottie/lottie.dart';

/// Two immutable compositions shared by every attempt in the auth flow.
class AuthResultCache {
  AuthResultCache({Future<LottieComposition> Function(String)? load})
    : _load = load ?? ((asset) => AssetLottie(asset).load());
  static final instance = AuthResultCache();
  static const success = 'assets/lottie/done.json';
  static const failure = 'assets/lottie/Failed.json';
  final Future<LottieComposition> Function(String) _load;
  final _entries = <String, Future<LottieComposition>>{};
  final _ready = <String, LottieComposition>{};

  /// Already-decoded assets render immediately without a FutureBuilder frame.
  LottieComposition? ready(String asset) => _ready[asset];

  Future<LottieComposition> composition(String asset) =>
      _entries.putIfAbsent(asset, () {
        final future = _load(asset);
        // Failed loads may retry on the next attempt; never strand navigation.
        unawaited(
          future.then<void>(
            (composition) { _ready[asset] = composition; },
            onError: (Object error, StackTrace stack) {
              _entries.remove(asset);
            },
          ),
        );
        return future;
      });

  void warmup() {
    for (final asset in [success, failure]) {
      unawaited(
        composition(
          asset,
        ).then<void>((_) {}, onError: (Object error, StackTrace stack) {}),
      );
    }
  }
}
