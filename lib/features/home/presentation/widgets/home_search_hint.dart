import 'package:material_ui/material_ui.dart';

/// Animates hint glyphs once while exposing the full hint to assistive tools.
class HomeSearchHint extends StatefulWidget {
  const HomeSearchHint({super.key, required this.text});
  final String text;

  @override
  State<HomeSearchHint> createState() => _HomeSearchHintState();
}

class _HomeSearchHintState extends State<HomeSearchHint>
    with SingleTickerProviderStateMixin {
  late final _typing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _typing.value = 1;
    } else if (_typing.isDismissed) {
      _typing.forward();
    }
  }

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.characters;
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _typing,
        builder: (context, _) => Text(
          characters
              .take((characters.length * _typing.value).ceil())
              .toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
