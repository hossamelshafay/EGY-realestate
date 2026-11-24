import 'package:material_ui/material_ui.dart';
import 'package:egy/core/widgets/locale_selector.dart';

/// Authentication locale controls backed by the shared persisted LocaleCubit.
class AuthLanguageSelector extends StatelessWidget {
  const AuthLanguageSelector({super.key});
  @override
  Widget build(BuildContext context) => const LocaleSelector();
}
