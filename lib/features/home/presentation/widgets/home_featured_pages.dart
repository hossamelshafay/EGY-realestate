import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/features/properties/domain/entities/property_listing.dart';
import 'package:egy/features/properties/presentation/cubit/catalog_cubit.dart';

import '../cubit/home_cubit.dart';
import 'home_featured_card.dart';

part 'home_carousel_indicators.dart';
part 'home_featured_strip.dart';

class _HomeFeaturedPagesState extends State<HomeFeaturedPages>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(vsync: this);
  final _countdown = _FeaturedCountdown();
  final _pointers = <int>{};
  late final AppLifecycleListener _lifecycle;
  late List<PropertyListing> _items;
  RenderBox? _viewport;
  var _index = 0;
  var _direction = 1;
  var _drag = 0.0;
  var _routeVisible = false;
  var _reduced = false;
  var _settling = false;

  @override
  void initState() {
    super.initState();
    _items = widget.filters.filter(widget.catalog.items);
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state != AppLifecycleState.resumed) _pointers.clear();
        _schedule();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _prefetch();
    });
  }

  bool get _foreground =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeVisible =
        (ModalRoute.isCurrentOf(context) ?? true) &&
        TickerMode.valuesOf(context).enabled;
    _reduced = MediaQuery.disableAnimationsOf(context);
    final viewport = Scrollable.maybeOf(context)?.context.findRenderObject();
    _viewport = viewport is RenderBox ? viewport : null;
    _schedule();
  }

  @override
  void didUpdateWidget(covariant HomeFeaturedPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.catalog.items, oldWidget.catalog.items)) {
      final wasEmpty = _items.isEmpty;
      _items = widget.filters.filter(widget.catalog.items);
      if (wasEmpty && _items.isNotEmpty) _schedule();
    }
  }

  @override
  void dispose() {
    _countdown.dispose();
    _motion.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _active =>
      mounted &&
      _routeVisible &&
      _foreground &&
      identical(context.read<CatalogCubit>().state, widget.catalog) &&
      context.read<HomeCubit>().state.filterKey == widget.filters.filterKey;

  bool _hasCard(int direction) =>
      _index + direction >= 0 && _index + direction < _items.length;

  void _schedule() {
    _countdown.pause();
    if (!_routeVisible ||
        !_foreground ||
        _reduced ||
        _settling ||
        _items.isEmpty ||
        _pointers.isNotEmpty) {
      return;
    }
    _countdown.start(
      visible: () => _active && _isOnScreen(context, _viewport),
      elapsed: (retry) {
        if (_hasCard(1)) {
          unawaited(_settle(1));
        } else if (retry) {
          _prefetch();
        }
      },
    );
  }

  void _prefetch() {
    if (_active && !widget.catalog.exhausted && _items.length - _index <= 3) {
      _prefetchListings(context);
    }
  }

  void _dragBy(double delta) {
    if (_settling) return;
    _drag = (_drag + delta).clamp(-1.0, 1.0);
    final direction = _drag < 0 ? -1 : 1;
    if (!_hasCard(direction)) {
      _motion.value = 0;
      return;
    }
    if (direction != _direction) setState(() => _direction = direction);
    if (!_reduced) _motion.value = _drag.abs();
  }

  void _release(double velocity) {
    final direction = _drag == 0 ? velocity.sign.toInt() : _drag.sign.toInt();
    final accepted = _drag.abs() > .22 || velocity * direction > 450;
    unawaited(_settle(accepted ? direction : 0));
  }

  Future<void> _settle(int direction) async {
    if (_settling) return;
    _settling = true;
    _countdown.pause();
    final advance = direction != 0 && _hasCard(direction);
    if (advance && direction != _direction) {
      setState(() => _direction = direction);
    }
    try {
      if (!_reduced) {
        await _motion
            .animateTo(
              advance ? 1 : 0,
              duration: Duration(milliseconds: advance ? 360 : 180),
              curve: Curves.easeOutCubic,
            )
            .orCancel;
      }
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    if (advance) {
      setState(() {
        _index += direction;
        _direction = 1;
      });
      _countdown.value = 0;
    }
    _drag = 0;
    _motion.value = 0;
    _settling = false;
    _prefetch();
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return _FeaturedEmpty(
        onRetry: widget.catalog.exhausted ? null : _prefetch,
      );
    }
    return _FeaturedStrip(
      front: _items[_index],
      behind: _hasCard(_direction) ? _items[_index + _direction] : null,
      cardHeight: widget.cardHeight,
      motion: _motion,
      direction: _direction,
      progress: _countdown,
      onPointer: (pointer, down) {
        down ? _pointers.add(pointer) : _pointers.remove(pointer);
        _schedule();
      },
      onDrag: _dragBy,
      onRelease: _release,
      onCancel: () => unawaited(_settle(0)),
      onNext: _hasCard(1) ? () => unawaited(_settle(1)) : null,
      onPrevious: _hasCard(-1) ? () => unawaited(_settle(-1)) : null,
    );
  }
}
