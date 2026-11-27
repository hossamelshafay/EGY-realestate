import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/widgets/skeleton/app_skeleton.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
import 'package:egy/features/profile/presentation/cubit/account_cubit.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Dedicated responsive Profile page for Flutter Web.
class WebProfilePage extends StatefulWidget {
  const WebProfilePage({super.key, this.cubit});

  final AccountCubit? cubit;

  @override
  State<WebProfilePage> createState() => _WebProfilePageState();
}

class _WebProfilePageState extends State<WebProfilePage> {
  late final AccountCubit _cubit;
  late final bool _ownsCubit;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedAvatar;
  String? _initializedForUid;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? (sl<AccountCubit>()..load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  String _noticeText(AppLocalizations l10n, String code) => switch (code) {
    'saved' => l10n.profileSaved,
    'verification-sent' => l10n.verificationSent,
    'email-updated' => l10n.emailUpdated,
    _ => code,
  };

  String _errorText(AppLocalizations l10n, String code) => switch (code) {
    'cloud-sync-pending' => l10n.profileSyncPending,
    'network-request-failed' => l10n.authNetwork,
    'requires-recent-login' || 'wrong-password' => l10n.accountReauthError,
    'permission-denied' => l10n.accountPermission,
    _ => l10n.accountUnavailable,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return BlocProvider.value(
      value: _cubit,
      child: SingleChildScrollView(
        child: WebPageContainer(
          maxWidth: WebBreakpoints.narrowContentMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebSectionHeader(
                title: l10n.profile,
                subtitle: l10n.profileAppearance,
                trailing: OutlinedButton.icon(
                  onPressed: () => context.go(RoutePaths.settings),
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: Text(l10n.settings),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AccountCubit, AccountState>(
                builder: (context, state) {
                  if (state is AccountLoading) {
                    return const SkeletonShimmer(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 300,
                        radius: 16,
                      ),
                    );
                  }
                  if (state is AccountFailed) {
                    return WebSurfaceCard(
                      child: Column(
                        children: [
                          Text(_errorText(l10n, state.code)),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => _cubit.load(),
                            child: Text(l10n.retryButton),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is! AccountReady) {
                    return const SizedBox.shrink();
                  }

                  final user = state.profile.user;
                  if (_initializedForUid != user.id) {
                    _initializedForUid = user.id;
                    _nameController.text = user.name ?? '';
                    _selectedAvatar =
                        user.avatarId ?? AvatarCatalog.ids.first;
                  }

                  final overviewCard = WebSurfaceCard(
                    child: Column(
                      children: [
                        ProfileAvatar(
                          avatarId: _selectedAvatar ?? user.avatarId,
                          size: 88,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          (user.name?.trim().isNotEmpty ?? false)
                              ? user.name!
                              : l10n.profile,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (user.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.email!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Chip(
                          avatar: Icon(
                            user.emailVerified
                                ? Icons.verified_outlined
                                : Icons.info_outline_rounded,
                            size: 18,
                          ),
                          label: Text(
                            user.emailVerified
                                ? l10n.emailVerified
                                : l10n.emailUnverified,
                          ),
                        ),
                        if (!user.emailVerified) ...[
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: state.busy
                                ? null
                                : () => _cubit.verify(),
                            child: Text(l10n.sendVerification),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: state.busy
                                ? null
                                : () => _cubit.load(),
                            child: Text(l10n.refreshAccount),
                          ),
                        ],
                      ],
                    ),
                  );

                  final editCard = WebSurfaceCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.editProfile,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.notice != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(_noticeText(l10n, state.notice!)),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (state.error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _errorText(l10n, state.error!),
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _nameController,
                            enabled: !state.busy,
                            decoration: InputDecoration(
                              labelText: l10n.accountDisplayName,
                            ),
                            validator: (v) {
                              final trimmed = v?.trim() ?? '';
                              if (trimmed.length < 2 || trimmed.length > 60) {
                                return l10n.accountNameRules;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.changeAvatar,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final id in AvatarCatalog.ids)
                                InkWell(
                                  onTap: state.busy
                                      ? null
                                      : () => setState(
                                          () => _selectedAvatar = id,
                                        ),
                                  borderRadius: BorderRadius.circular(36),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _selectedAvatar == id
                                            ? AppColors.primaryGold
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: ProfileAvatar(
                                      avatarId: id,
                                      size: 56,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: FilledButton(
                              onPressed: state.busy
                                  ? null
                                  : () {
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        return;
                                      }
                                      _cubit.save(
                                        _nameController.text.trim(),
                                        _selectedAvatar ??
                                            AvatarCatalog.ids.first,
                                      );
                                    },
                              child: state.busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.accountSave),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: overviewCard),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: editCard),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      overviewCard,
                      const SizedBox(height: 20),
                      editCard,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
