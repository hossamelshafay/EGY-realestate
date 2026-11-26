import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';
import 'package:egy/features/properties/presentation/property_type_label.dart';
import 'package:egy/features/properties/presentation/widgets/property_hero.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_search_cubit.dart';
import 'home_search_hint.dart';

/// Edits the retained Home query and presents backend-backed suggestions.
class HomeSearchPanel extends StatefulWidget {
  const HomeSearchPanel({super.key, required this.home, required this.catalog});

  final HomeCubit home;
  final CatalogState catalog;

  @override
  State<HomeSearchPanel> createState() => _HomeSearchPanelState();
}

class _HomeSearchPanelState extends State<HomeSearchPanel> {
  late final _text = TextEditingController(text: widget.home.state.query);
  final _focus = FocusNode();
  Animation<double>? _routeMotion;
  bool _didFocus = false;
  String? _language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = AppLocalizations.of(context).localeName;
    if (_language != language) {
      _language = language;
      _search(immediate: true);
    }
    final animation = ModalRoute.of(context)?.animation;
    if (_routeMotion != animation) {
      _routeMotion?.removeStatusListener(_focusOnOpen);
      _routeMotion = animation;
      animation?.addStatusListener(_focusOnOpen);
    }
    _focusOnOpen(animation?.status ?? AnimationStatus.completed);
  }

  void _focusOnOpen(AnimationStatus status) {
    if (_didFocus || status != AnimationStatus.completed) return;
    _didFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (ModalRoute.isCurrentOf(context) ?? true)) {
        _focus.requestFocus();
      }
    });
  }

  void _search({bool immediate = false}) {
    final l = AppLocalizations.of(context);
    final filters = widget.home.state;
    final catalog = widget.catalog;
    context.read<HomeSearchCubit>().search(
      text: _text.text,
      category: catalog.category,
      sample: catalog is CatalogReady ? catalog.items : const [],
      typeLabels: {
        for (final code in propertyTypeCodes) code.toLowerCase(): code,
        for (final code in propertyTypeCodes)
          propertyTypeLabel(l, code).toLowerCase(): code,
      },
      type: filters.type,
      city: filters.location,
      immediate: immediate,
    );
  }

  @override
  void dispose() {
    _routeMotion?.removeStatusListener(_focusOnOpen);
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _text,
                  builder: (context, value, _) => TextField(
                    key: const Key('home_search_query'),
                    controller: _text,
                    focusNode: _focus,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      widget.home.search(value);
                      _search();
                    },
                    onSubmitted: (_) => _search(immediate: true),
                    decoration: InputDecoration(
                      labelText: l.search,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hint: value.text.isEmpty
                          ? HomeSearchHint(text: l.homeSearchHint)
                          : null,
                      prefixIcon: const Icon(Icons.search_rounded),
                      prefixIconColor: AppColors.secondaryGold,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key('home_search_close'),
                tooltip: l.close,
                onPressed: () {
                  _focus.unfocus();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<HomeSearchCubit, HomeSearchState>(
            builder: (context, state) => ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l.homeSearchSuggestions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state is HomeSearchLoading) ...[
                  const SizedBox(height: 8),
                  const SkeletonSearchSuggestions(),
                ],
                const SizedBox(height: 8),
                if (state is HomeSearchReady && state.items.isEmpty)
                  Text(l.noResultsFound),
                for (final property in state.items)
                  _SearchSuggestion(property: property, focus: _focus),
                if (state case HomeSearchError(:final failure))
                  AiFeedback(
                    failure: failure,
                    onRetry: () => _search(immediate: true),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchSuggestion extends StatelessWidget {
  const _SearchSuggestion({required this.property, required this.focus});

  final PropertyListing property;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    final preview = PropertyPreview(property, (_SearchSuggestion, property.id));
    return ListTile(
      key: ValueKey('home_search_result_${property.id}'),
      leading: SizedBox(
        width: 64,
        height: 48,
        child: PropertyHero(property: property, tag: preview.tag, radius: 8),
      ),
      title: Text(property.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        property.location,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: GoRouter.maybeOf(context) == null
          ? null
          : () {
              focus.unfocus();
              preview.open(context);
            },
    );
  }
}
