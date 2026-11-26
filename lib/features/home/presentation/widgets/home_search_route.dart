import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_search_cubit.dart';
import 'home_search_panel.dart';

/// A modal search surface that grows out of the Home search control.
abstract final class HomeSearchRoute {
  static void open(BuildContext anchor) {
    final navigator = Navigator.of(anchor);
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final box = anchor.findRenderObject()! as RenderBox;
    final source = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    final catalog = anchor.read<CatalogCubit>().state;
    final home = anchor.read<HomeCubit>();
    final reduced = MediaQuery.disableAnimationsOf(anchor);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 340);

    navigator.push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (_, animation, _) => BlocProvider(
          create: (_) => sl<HomeSearchCubit>(),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: _SearchSurface(
              source: source,
              animation: animation,
              child: HomeSearchPanel(home: home, catalog: catalog),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchSurface extends StatelessWidget {
  const _SearchSurface({
    required this.source,
    required this.animation,
    required this.child,
  });

  final Rect source;
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, bounds) {
        final width = math.min(640.0, bounds.maxWidth - 32);
        final top = media.viewPadding.top + 16;
        final bottom =
            math.max(media.viewPadding.bottom, media.viewInsets.bottom) + 12;
        final height = math.max(0.0, bounds.maxHeight - top - bottom);
        final target = Rect.fromLTWH(
          (bounds.maxWidth - width) / 2,
          top,
          width,
          height,
        );
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final t = Curves.easeInOutCubic.transform(animation.value);
            final rect = Rect.lerp(source, target, t)!;
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: _SearchBackdrop(
                      opacity: t,
                      blur: media.disableAnimations ? 0 : 6 * t,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minWidth: width,
                      maxWidth: width,
                      minHeight: height,
                      maxHeight: height,
                      child: Opacity(
                        opacity: const Interval(.22, .75).transform(t),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SearchBackdrop extends StatelessWidget {
  const _SearchBackdrop({required this.opacity, required this.blur});

  final double opacity, blur;

  @override
  Widget build(BuildContext context) {
    final dim = ColoredBox(
      color: AppColors.primaryNavy.withValues(alpha: .52 * opacity),
    );
    if (blur < .1) return dim;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: dim,
    );
  }
}
