import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import '../../domain/entities/account_profile.dart';
import '../../domain/entities/avatar_catalog.dart';
import '../cubit/account_cubit.dart';
import '../widgets/account_scope.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_summary.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.edit = false});
  final bool edit;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AccountScope(
      title: edit ? l.editProfile : l.profile,
      onSaved: edit
          ? () {
              final router = GoRouter.maybeOf(context);
              if (router != null && router.canPop()) {
                router.pop(true);
              } else {
                Navigator.of(context).maybePop(true);
              }
            }
          : null,
      builder: (context, state) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: edit
            ? _ProfileForm(profile: state.profile, busy: state.busy)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileSummary(profile: state.profile),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    key: const Key('profile_edit_button'),
                    onPressed: () async {
                      final saved = await context.pushNamed<bool>(
                        RouteNames.editProfile,
                      );
                      if (saved == true && context.mounted) {
                        context.read<AccountCubit>().load();
                      }
                    },
                    child: Text(l.editProfile),
                  ),
                  TextButton(
                    onPressed: context.read<AccountCubit>().load,
                    child: Text(l.refreshAccount),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.profile, required this.busy});
  final AccountProfile profile;
  final bool busy;
  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.profile.user.name ?? '',
  );
  late String _avatar = widget.profile.user.avatarId ?? AvatarCatalog.ids.first;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ProfileAvatar(
              key: const Key('edit_profile_avatar_preview'),
              avatarId: _avatar,
              size: 92,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const Key('profile_name'),
            controller: _name,
            maxLength: 60,
            decoration: InputDecoration(labelText: l.accountDisplayName),
            validator: (value) =>
                (value?.trim().length ?? 0) < 2 ? l.accountNameRules : null,
          ),
          const SizedBox(height: 24),
          AvatarPicker(
            value: _avatar,
            onChanged: (value) => setState(() => _avatar = value),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('profile_save'),
            onPressed: widget.busy
                ? null
                : () {
                    if (_form.currentState!.validate()) {
                      context.read<AccountCubit>().save(_name.text, _avatar);
                    }
                  },
            child: widget.busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.accountSave),
          ),
        ],
      ),
    );
  }
}
