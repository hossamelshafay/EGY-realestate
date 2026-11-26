import 'package:egy/app/di/injection.dart';
import 'package:egy/app/localization/app_localization_config.dart';
import 'package:egy/features/profile/presentation/pages/account_security_page.dart';
import 'package:egy/features/profile/presentation/pages/profile_page.dart';
import 'package:egy/features/profile/presentation/pages/settings_page.dart';
import 'package:egy/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:egy/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:egy/features/profile/domain/entities/avatar_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../support/account_repository.dart';

Widget app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizationConfig.delegates,
  supportedLocales: const [Locale('en'), Locale('ar')],
  home: child,
);

void main() {
  tearDown(() => sl.reset());
  testWidgets('all six avatars select and an empty registration selection is rejected', (tester) async {
    final key = GlobalKey<FormState>();
    String? selected;
    await tester.pumpWidget(app(Scaffold(body: Form(key: key, child: AvatarPicker(onChanged: (id) => selected = id)))));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Choose an avatar before continuing.'), findsOneWidget);
    for (final id in AvatarCatalog.ids) {
      await tester.tap(find.byKey(ValueKey('avatar_$id'))); await tester.pump();
      expect(selected, id); expect(key.currentState!.validate(), isTrue);
    }
  });
  testWidgets('profile saves name/avatar and retains the account email', (tester) async {
    final repository = registerTestAccount();
    await tester.pumpWidget(app(const ProfilePage(edit: true))); await tester.pumpAndSettle();
    expect(
      tester.widget<ProfileAvatar>(find.byKey(const Key('edit_profile_avatar_preview'))).avatarId,
      'nile',
    );
    await tester.enterText(find.byKey(const Key('profile_name')), 'Updated name');
    await tester.tap(find.byKey(const ValueKey('avatar_yasmin')));
    await tester.pump();
    expect(
      tester.widget<ProfileAvatar>(find.byKey(const Key('edit_profile_avatar_preview'))).avatarId,
      'yasmin',
    );
    await tester.tap(find.byKey(const Key('profile_save'))); await tester.pumpAndSettle();
    expect(repository.profile.user.name, 'Updated name');
    expect(repository.profile.user.avatarId, 'yasmin');
    expect(repository.profile.user.email, 'test@example.com');
    expect(find.text('Saved'), findsOneWidget);
  });
  testWidgets('settings omits redundant Change avatar row', (tester) async {
    registerTestAccount();
    await tester.pumpWidget(app(const SettingsPage())); await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Change avatar'), findsNothing);
  });
  testWidgets('successful save pops back to Profile and shows updated name and avatar', (tester) async {
    registerTestAccount();
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(name: 'profile', path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(name: 'editProfile', path: '/settings/profile', builder: (_, _) => const ProfilePage(edit: true)),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      localizationsDelegates: AppLocalizationConfig.delegates,
      supportedLocales: const [Locale('en'), Locale('ar')],
      routerConfig: router,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_edit_button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile_name')), 'Noura Ali');
    await tester.tap(find.byKey(const ValueKey('avatar_noura')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Noura Ali'), findsOneWidget);
    expect(tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).avatarId, 'noura');
    await tester.tap(find.byKey(const Key('profile_edit_button')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(find.byKey(const Key('profile_name'))).controller!.text, 'Noura Ali');
    expect(
      tester.widget<ProfileAvatar>(find.byKey(const Key('edit_profile_avatar_preview'))).avatarId,
      'noura',
    );
  });
  testWidgets('cloud sync failure keeps Edit Profile open and preserves unsaved edits for retry', (tester) async {
    final repository = registerTestAccount()..synced = false;
    await tester.pumpWidget(app(const ProfilePage(edit: true)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile_name')), 'Unsaved Name');
    await tester.tap(find.byKey(const ValueKey('avatar_lotus')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_name')), findsOneWidget);
    expect(tester.widget<TextFormField>(find.byKey(const Key('profile_name'))).controller!.text, 'Unsaved Name');
    expect(
      tester.widget<ProfileAvatar>(find.byKey(const Key('edit_profile_avatar_preview'))).avatarId,
      'lotus',
    );
    expect(find.text('Cloud profile sync failed. Retry Save to sync your changes.'), findsOneWidget);
    repository.synced = true;
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();
    expect(repository.profile.user.name, 'Unsaved Name');
    expect(repository.profile.user.avatarId, 'lotus');
    expect(find.text('Saved'), findsOneWidget);
  });
  testWidgets('email update requests verification without locally replacing identity', (tester) async {
    final repository = registerTestAccount();
    await tester.pumpWidget(app(const AccountSecurityPage(action: AccountAction.email))); await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account_current_password')), 'test password');
    await tester.enterText(find.byKey(const Key('account_replacement')), 'new@example.com');
    await tester.tap(find.byKey(const Key('account_submit'))); await tester.pumpAndSettle();
    expect(repository.calls, ['email']); expect(repository.profile.user.email, 'test@example.com');
    expect(find.textContaining('Verify the new email'), findsOneWidget);
  });
  testWidgets('password confirmation is required before a secure operation', (tester) async {
    final repository = registerTestAccount();
    await tester.pumpWidget(app(const AccountSecurityPage(action: AccountAction.password))); await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account_current_password')), 'test password');
    await tester.enterText(find.byKey(const Key('account_replacement')), 'new-password');
    await tester.enterText(find.byKey(const Key('account_confirm_password')), 'mismatch');
    await tester.tap(find.byKey(const Key('account_submit'))); await tester.pumpAndSettle();
    expect(repository.calls, isEmpty); expect(find.text('Passwords do not match.'), findsOneWidget);
  });
  testWidgets('account deletion cancellation never invokes the repository', (tester) async {
    final repository = registerTestAccount();
    await tester.pumpWidget(app(const AccountSecurityPage(action: AccountAction.delete))); await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account_current_password')), 'test password');
    await tester.tap(find.byKey(const Key('account_submit'))); await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel')); await tester.pumpAndSettle();
    expect(repository.calls, isEmpty);
  });
}
