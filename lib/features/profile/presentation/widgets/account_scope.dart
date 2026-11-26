import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import '../cubit/account_cubit.dart';
import 'account_messages.dart';

class AccountScope extends StatelessWidget {
  const AccountScope({
    super.key,
    required this.title,
    required this.builder,
    this.onSaved,
  });
  final String title;
  final Widget Function(BuildContext, AccountReady) builder;
  final VoidCallback? onSaved;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<AccountCubit>()..load(),
    child: _AccountSessionSync(child: AuthenticatedScaffold(
      title: title,
      child: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, state) {
          if (state is AccountReady) {
            if (sl.isRegistered<SessionCubit>() &&
                sl<SessionCubit>().state.user?.email !=
                    state.profile.user.email) {
              sl<SessionCubit>().refresh(force: true);
            }
          }
          if (state is AccountReady &&
              (state.error != null || state.notice != null)) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    accountMessage(
                      AppLocalizations.of(context),
                      state.error ?? state.notice!,
                    ),
                  ),
                ),
              );
            if (state.error == null && state.notice == 'saved') {
              onSaved?.call();
            }
          }
        },
        builder: (context, state) => switch (state) {
          AccountReady() => builder(context, state),
          AccountFailed(:final code) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    accountMessage(AppLocalizations.of(context), code),
                  ),
                ),
                TextButton(
                  onPressed: context.read<AccountCubit>().load,
                  child: Text(AppLocalizations.of(context).retryButton),
                ),
              ],
            ),
          ),
          AccountDeleted() => const SizedBox.shrink(),
          _ => const SkeletonProfile(),
        },
      ),
    )),
  );
}

class _AccountSessionSync extends StatelessWidget {
  const _AccountSessionSync({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!sl.isRegistered<SessionCubit>()) return child;
    return BlocListener<SessionCubit, SessionState>(bloc: sl<SessionCubit>(),
      listenWhen: (before, after) => before.user?.name != after.user?.name ||
        before.user?.avatarId != after.user?.avatarId || before.user?.email != after.user?.email ||
        before.user?.emailVerified != after.user?.emailVerified,
      listener: (context, state) {
        final cubit = context.read<AccountCubit>();
        if (state.user != null && !(cubit.state is AccountReady && (cubit.state as AccountReady).busy)) {
          cubit.load();
        }
      }, child: child);
  }
}
