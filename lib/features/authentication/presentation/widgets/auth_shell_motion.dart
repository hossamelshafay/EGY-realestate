import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../pages/auth_page_mode.dart';

/// Explicit phases prevent routing, asset loads and repeated failures from racing.
enum AuthMotionPhase {
  idle,
  switching,
  expandingSuccess,
  expandingFailure,
  successResult,
  failureResult,
  returningFailure,
  awaitingHome,
  revealingHome,
}

/// Ephemeral presentation clocks for one persistent navy surface and form.
class AuthShellMotion extends ChangeNotifier {
  AuthShellMotion({
    required TickerProvider vsync,
    required AuthPageMode initialMode,
    required bool initiallyHome,
    required this.onSuccessReady,
  }) {
    fromMode = toMode = initialMode;
    _fromMirror = _toMirror = initialMode == AuthPageMode.register ? 1 : 0;
    _fromReset = _toReset = initialMode == AuthPageMode.reset ? 1 : 0;
    mode = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 750),
      value: 1,
    );
    cover = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 520),
    );
    home = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
      value: initiallyHome ? 1 : 0,
    );
    result = AnimationController(vsync: vsync);
    shake = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 420),
    );
    for (final clock in [mode, cover, home]) {
      clock.addListener(notifyListeners);
    }
    result.addStatusListener((status) {
      if (status == AnimationStatus.completed) _resultFinished();
    });
    home.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          phase == AuthMotionPhase.revealingHome) {
        phase = AuthMotionPhase.idle;
        _notify();
      }
    });
  }
  late final AnimationController mode, cover, home, result, shake;
  final VoidCallback onSuccessReady;
  late AuthPageMode fromMode, toMode;
  late double _fromMirror, _toMirror, _fromReset, _toReset;
  final feedback = ValueNotifier<int>(0);
  double get reset =>
      _fromReset +
      (_toReset - _fromReset) * Curves.easeInOutCubic.transform(mode.value);
  AuthMotionPhase phase = AuthMotionPhase.idle;
  bool reduced = false,
      inlineReady = false,
      _disposed = false,
      _resultStarted = false;
  int _resultRevision = 0;
  String? errorCode;
  bool _loading = false;
  void _notify() {
    feedback.value++;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    _notify();
  }

  bool get switching => phase == AuthMotionPhase.switching;
  bool get busy => _loading || phase != AuthMotionPhase.idle;
  bool get showingResult =>
      phase == AuthMotionPhase.successResult ||
      phase == AuthMotionPhase.failureResult;
  bool get successfulResult => phase == AuthMotionPhase.successResult;
  AuthPageMode get visibleMode =>
      switching && mode.value < .5 ? fromMode : toMode;
  double get mirror =>
      _fromMirror +
      (_toMirror - _fromMirror) * Curves.easeInOutCubic.transform(mode.value);
  double get fold => switching
      ? math.sin(math.pi * Curves.easeInOutCubic.transform(mode.value))
      : 0;
  double get formOpacity =>
      (switching
          ? Curves.easeOutCubic.transform((2 * mode.value - 1).abs())
          : 1) *
      (1 - cover.value);
  double get expansion => cover.value * (1 - home.value);

  void clearError() {
    errorCode = null;
    inlineReady = false;
    shake.stop();
    shake.value = 0;
    _notify();
  }

  Future<void> switchTo(AuthPageMode target) async {
    final current = visibleMode;
    if (target == current && !switching) return;
    final currentMirror = mirror;
    final currentReset = reset;
    fromMode = current;
    toMode = target;
    _fromMirror = currentMirror;
    _toMirror = target == AuthPageMode.register ? 1 : 0;
    _fromReset = currentReset;
    _toReset = target == AuthPageMode.reset ? 1 : 0;
    phase = AuthMotionPhase.switching;
    inlineReady = false;
    mode.value = 0;
    _notify();
    try {
      if (reduced) {
        mode.value = 1;
      } else {
        await mode.forward().orCancel;
      }
      if (!_disposed) {
        phase = AuthMotionPhase.idle;
        _notify();
      }
    } on TickerCanceled {
      /* The shell was removed. */
    }
  }

  Future<void> showSuccess() async {
    if (phase == AuthMotionPhase.expandingSuccess ||
        phase == AuthMotionPhase.successResult ||
        phase == AuthMotionPhase.awaitingHome ||
        phase == AuthMotionPhase.revealingHome) {
      return;
    }
    _resultRevision++;
    // Success may interrupt failure feedback; failure count never gates success.
    mode.stop();
    cover.stop();
    result.stop();
    _loading = false;
    clearError();
    _resultStarted = false;
    result.value = 0;
    phase = AuthMotionPhase.expandingSuccess;
    _notify();
    try {
      if (reduced) {
        cover.value = 1;
      } else {
        await cover.forward(from: cover.value).orCancel;
      }
      if (!_disposed) {
        phase = AuthMotionPhase.successResult;
        _notify();
      }
    } on TickerCanceled {
      /* The shell was removed. */
    }
  }

  Future<void> showFailure(String code, int attempt) async {
    errorCode = code;
    if (attempt != 1) {
      inlineReady = true;
      if (!reduced && attempt > 1) shake.forward(from: 0);
      _notify();
      return;
    }
    _resultRevision++;
    _resultStarted = false;
    result.value = 0;
    inlineReady = false;
    phase = AuthMotionPhase.expandingFailure;
    _notify();
    try {
      if (reduced) {
        cover.value = 1;
      } else {
        await cover.forward(from: 0).orCancel;
      }
      if (!_disposed) {
        phase = AuthMotionPhase.failureResult;
        _notify();
      }
    } on TickerCanceled {
      /* The shell was removed. */
    }
  }

  /// Called only by a loaded Lottie, after the full-screen surface is established.
  void playResult(Duration duration) {
    if (_resultStarted || !showingResult || _disposed) return;
    _resultStarted = true;
    result.duration = duration;
    final revision = _resultRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !showingResult || revision != _resultRevision) return;
      if (reduced) {
        result.value = 1;
      } else {
        result.forward(from: 0);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Invalid/missing assets cannot leave an authenticated user stuck on a cover.
  void resultUnavailable() {
    if (_resultStarted) return;
    playResult(const Duration(milliseconds: 1));
  }

  void _resultFinished() {
    if (phase == AuthMotionPhase.successResult) {
      phase = AuthMotionPhase.awaitingHome;
      _notify();
      onSuccessReady();
    } else if (phase == AuthMotionPhase.failureResult) {
      unawaited(returnToForm());
    }
  }

  Future<void> returnToForm() async {
    phase = AuthMotionPhase.returningFailure;
    _notify();
    try {
      if (reduced) {
        cover.value = 0;
      } else {
        await cover.reverse().orCancel;
      }
      if (!_disposed) {
        phase = AuthMotionPhase.idle;
        inlineReady = true;
        _notify();
      }
    } on TickerCanceled {
      /* The shell was removed. */
    }
  }

  void revealHome() {
    phase = AuthMotionPhase.revealingHome;
    _notify();
    if (reduced) {
      home.value = 1;
    } else {
      home.forward(from: 0);
    }
  }

  void resetAuth(AuthPageMode target) {
    _resultRevision++;
    _resultStarted = false;
    for (final clock in [mode, cover, home, result, shake]) {
      clock.stop();
    }
    fromMode = toMode = target;
    _fromMirror = _toMirror = target == AuthPageMode.register ? 1 : 0;
    _fromReset = _toReset = target == AuthPageMode.reset ? 1 : 0;
    phase = AuthMotionPhase.idle;
    _loading = false;
    cover.value = 0;
    home.value = 0;
    mode.value = 1;
    clearError();
  }

  void settleReducedMotion() {
    reduced = true;
    switch (phase) {
      case AuthMotionPhase.switching:
        mode.value = 1;
        phase = AuthMotionPhase.idle;
      case AuthMotionPhase.expandingSuccess:
        cover.value = 1;
        phase = AuthMotionPhase.successResult;
      case AuthMotionPhase.expandingFailure:
        cover.value = 1;
        phase = AuthMotionPhase.failureResult;
      case AuthMotionPhase.returningFailure:
        cover.value = 0;
        phase = AuthMotionPhase.idle;
        inlineReady = true;
      case AuthMotionPhase.successResult || AuthMotionPhase.failureResult:
        if (_resultStarted) result.value = 1;
      case AuthMotionPhase.revealingHome:
        home.value = 1;
      case AuthMotionPhase.awaitingHome || AuthMotionPhase.idle:
        break;
    }
    shake.stop();
    shake.value = 0;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final clock in [mode, cover, home, result, shake]) {
      clock.dispose();
    }
    feedback.dispose();
    super.dispose();
  }
}
