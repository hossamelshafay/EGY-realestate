part of 'home_featured_pages.dart';

class _FeaturedCountdown extends ValueNotifier<double> {
  _FeaturedCountdown() : super(0);

  static const _step = Duration(milliseconds: 125);
  static final _ticks =
      const Duration(seconds: 5).inMilliseconds ~/ _step.inMilliseconds;
  Timer? _timer;

  void start({
    required bool Function() visible,
    required ValueChanged<bool> elapsed,
  }) {
    var progress = value;
    var baseline = 0;
    var nextRetry = 0;
    _timer = Timer.periodic(_step, (timer) {
      if (!visible()) {
        baseline = timer.tick;
        progress = value = 0;
        nextRetry = 0;
        return;
      }
      value = (progress + (timer.tick - baseline) / _ticks).clamp(0.0, 1.0);
      if (value < 1) return;
      final retry = timer.tick >= nextRetry;
      if (retry) nextRetry = timer.tick + _ticks;
      elapsed(retry);
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    pause();
    super.dispose();
  }
}

class _FeaturedProgress extends StatelessWidget {
  const _FeaturedProgress(this.progress);
  final ValueListenable<double> progress;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: progress,
    builder: (context, value, _) => SizedBox(
      width: 96,
      child: LinearProgressIndicator(
        key: const Key('home_featured_progress'),
        value: value,
        minHeight: 3,
        trackGap: 0,
        stopIndicatorRadius: 0,
        borderRadius: BorderRadius.circular(4),
        color: AppColors.primaryGold,
        backgroundColor: AppColors.primaryGold.withValues(alpha: .16),
      ),
    ),
  );
}
