import 'package:material_ui/material_ui.dart';

import 'package:egy/app/theme/app_colors.dart';

/// Theme-aware shimmer sweep that pauses when off-screen or reduced-motion.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});
  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active =
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced =
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkInput : AppColors.shimmerBase;
    final highlight = isDark
        ? AppColors.darkOutline.withValues(alpha: 0.45)
        : AppColors.shimmerHighlight;

    if (reduced) {
      return ExcludeSemantics(child: widget.child);
    }

    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            final t = _controller.value * 2 - 1;
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(-1.0 + t, -0.2),
                end: Alignment(1.0 + t, 0.2),
                colors: [base, highlight, base],
                stops: const [0.15, 0.5, 0.85],
              ).createShader(bounds),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// Rounded placeholder block using approved light/dark skeleton tokens.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInput : AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton matching [ListingCard] geometry.
class SkeletonListingCard extends StatelessWidget {
  const SkeletonListingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 160, radius: 0),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 190, height: 18, radius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 130, height: 14, radius: 6),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBox(width: 64, height: 22, radius: 12),
                      SizedBox(width: 8),
                      SkeletonBox(width: 64, height: 22, radius: 12),
                      SizedBox(width: 8),
                      SkeletonBox(width: 64, height: 22, radius: 12),
                    ],
                  ),
                  SizedBox(height: 12),
                  SkeletonBox(width: 120, height: 20, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonListingList extends StatelessWidget {
  const SkeletonListingList({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      key: const Key('skeleton_listing_list'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (var i = 0; i < count; i++) const SkeletonListingCard()],
      ),
    );
  }
}

/// Skeleton matching [HomeFeaturedCard] inside [HomeFeaturedCarousel].
class SkeletonFeaturedCard extends StatelessWidget {
  const SkeletonFeaturedCard({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      key: const Key('skeleton_featured_card'),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SkeletonBox(height: height, radius: 24),
              const PositionedDirectional(
                start: 16,
                end: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 18, radius: 6),
                    SizedBox(height: 8),
                    SkeletonBox(width: 120, height: 14, radius: 6),
                    SizedBox(height: 10),
                    SkeletonBox(width: 100, height: 22, radius: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton matching [HomeSearchPanel] suggestion rows.
class SkeletonSearchSuggestions extends StatelessWidget {
  const SkeletonSearchSuggestions({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      key: const Key('skeleton_search_suggestions'),
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SkeletonBox(width: 64, height: 48, radius: 8),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 170, height: 15, radius: 6),
                        SizedBox(height: 6),
                        SkeletonBox(width: 110, height: 12, radius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Skeleton matching [PropertyDetailsContent].
class SkeletonDetailsBody extends StatelessWidget {
  const SkeletonDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      key: Key('skeleton_details_body'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 220, height: 24, radius: 8),
          SizedBox(height: 10),
          SkeletonBox(width: 140, height: 20, radius: 6),
          SizedBox(height: 16),
          Row(
            children: [
              SkeletonBox(width: 72, height: 28, radius: 14),
              SizedBox(width: 8),
              SkeletonBox(width: 72, height: 28, radius: 14),
              SizedBox(width: 8),
              SkeletonBox(width: 72, height: 28, radius: 14),
            ],
          ),
          SizedBox(height: 20),
          SkeletonBox(height: 14, radius: 6),
          SizedBox(height: 8),
          SkeletonBox(height: 14, radius: 6),
          SizedBox(height: 8),
          SkeletonBox(width: 240, height: 14, radius: 6),
        ],
      ),
    );
  }
}

/// Skeleton matching [ProfileSummary] and [SettingsPage].
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      key: Key('skeleton_profile'),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SkeletonBox(width: 92, height: 92, radius: 46),
            SizedBox(height: 16),
            SkeletonBox(width: 160, height: 22, radius: 8),
            SizedBox(height: 8),
            SkeletonBox(width: 200, height: 14, radius: 6),
            SizedBox(height: 28),
            SkeletonBox(height: 48, radius: 24),
            SizedBox(height: 12),
            SkeletonBox(height: 48, radius: 24),
          ],
        ),
      ),
    );
  }
}

/// Skeleton matching [PredictionForm] while model options load.
class SkeletonPredictionForm extends StatelessWidget {
  const SkeletonPredictionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      key: Key('skeleton_prediction_form'),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(width: 180, height: 22, radius: 8),
            SizedBox(height: 20),
            SkeletonBox(height: 54, radius: 14),
            SizedBox(height: 16),
            SkeletonBox(height: 54, radius: 14),
            SizedBox(height: 16),
            SkeletonBox(height: 54, radius: 14),
            SizedBox(height: 16),
            SkeletonBox(height: 54, radius: 14),
            SizedBox(height: 24),
            SkeletonBox(height: 52, radius: 26),
          ],
        ),
      ),
    );
  }
}

/// Skeleton matching [PredictionResult] while inference is running.
class SkeletonPredictionResult extends StatelessWidget {
  const SkeletonPredictionResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      key: Key('skeleton_prediction_result'),
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 16, radius: 6),
                SizedBox(height: 10),
                SkeletonBox(width: 200, height: 28, radius: 8),
                SizedBox(height: 10),
                SkeletonBox(width: 160, height: 14, radius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
