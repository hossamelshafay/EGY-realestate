import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../../domain/entities/account_profile.dart';
import '../cubit/account_cubit.dart';
import 'profile_avatar.dart';

class ProfileSummary extends StatelessWidget {
  const ProfileSummary({super.key, required this.profile});
  final AccountProfile profile;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = profile.user;
    return Column(
      children: [
        ProfileAvatar(avatarId: user.avatarId, size: 92),
        const SizedBox(height: 16),
        Text(
          user.name?.trim().isNotEmpty == true ? user.name! : l.homeWelcome,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (user.email case final email?) ...[
          const SizedBox(height: 8),
          Text(
            email,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                user.emailVerified
                    ? Icons.verified_outlined
                    : Icons.info_outline,
                size: 18,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  user.emailVerified ? l.emailVerified : l.emailUnverified,
                ),
              ),
            ],
          ),
          if (!user.emailVerified)
            TextButton(
              onPressed: context.read<AccountCubit>().verify,
              child: Text(l.sendVerification),
            ),
        ],
      ],
    );
  }
}
