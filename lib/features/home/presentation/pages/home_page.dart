import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:egy/app/di/injection.dart';
import 'package:egy/core/widgets/session_morph_scope.dart';
import 'package:egy/app/router/screen_handoff.dart';
import 'package:egy/core/widgets/session_scroll_scope.dart';
import 'package:egy/features/properties/domain/entities/property_category.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';

import '../cubit/home_cubit.dart';
import '../widgets/home_ai_tools.dart';
import '../widgets/home_discovery.dart';
import '../widgets/home_featured_carousel.dart';
import '../widgets/home_palette.dart';
import '../widgets/home_stage.dart';

/// Content only: the existing navy header and morph remain owned by SessionPage.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<HomeCubit>()),
      BlocProvider(
        create: (_) =>
            CatalogCubit(sl(), PropertyCategory.residentialSale, limit: 5)
              ..refresh(),
      ),
    ],
    child: const _HomeContent(),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    final handoff = HandoffScope.of(context);
    final entry =
        (handoff?.incoming == true ? handoff?.notifier?.value : null) ?? 1.0;
    final t = (SessionMorphScope.of(context)?.notifier?.value ?? 1.0).clamp(
      0.0,
      entry,
    );
    final background = Interval(.4, .9, curve: Curves.easeInOut).transform(t);
    return ColoredBox(
      key: const Key('home_canvas'),
      color: HomePalette.canvas(context).withValues(alpha: background),
      child: const _HomeSections(),
    );
  }
}

class _HomeSections extends StatelessWidget {
  const _HomeSections();
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeStage(stage: 1, child: HomeDiscovery()),
                  SizedBox(height: 20),
                  HomeFeaturedCarousel(),
                  SizedBox(height: 16),
                  HomeStage(stage: 4, child: HomeAiTools()),
                ],
              ),
            ),
          ),
        );
        return SessionScrollScope.contains(context)
            ? content
            : SingleChildScrollView(
                key: const Key('home_scroll'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: content,
              );
      },
    );
  }
}
