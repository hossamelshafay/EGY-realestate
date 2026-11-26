import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'auth_entrance.dart';
import 'google_logo.dart';

/// Shared social sign-in actions retain the established entrance sequence.
class AuthSocialActions extends StatelessWidget {
  const AuthSocialActions({super.key, required this.loading, required this.onGoogle});
  final bool loading;
  final VoidCallback onGoogle;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 24),
      AuthEntranceStage(stage: 7, child: Row(children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(l.orContinue, style: Theme.of(context).textTheme.bodyMedium)),
        const Expanded(child: Divider()),
      ])),
      const SizedBox(height: 16),
      AuthEntranceStage(stage: 8, child: OutlinedButton.icon(key: const Key('auth_google'),
        onPressed: loading ? null : onGoogle, icon: const GoogleLogo(), label: Text(l.continueGoogle),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
    ]);
  }
}
