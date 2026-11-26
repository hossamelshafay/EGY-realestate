import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy/core/errors/failures.dart';
import '../../domain/entities/account_profile.dart';
import '../../domain/repositories/account_repository.dart';

sealed class AccountState {
  const AccountState();
}

final class AccountLoading extends AccountState {
  const AccountLoading();
}

final class AccountReady extends AccountState {
  const AccountReady(
    this.profile, {
    this.busy = false,
    this.error,
    this.notice,
  });
  final AccountProfile profile;
  final bool busy;
  final String? error, notice;
}

final class AccountFailed extends AccountState {
  const AccountFailed(this.code);
  final String code;
}

final class AccountDeleted extends AccountState {
  const AccountDeleted();
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this.repository) : super(const AccountLoading());
  final AccountRepository repository;
  int _loadEpoch = 0;
  String? _pendingEmail;
  Future<void> load() async {
    final epoch = ++_loadEpoch;
    try {
      final value = await repository.load();
      if (!isClosed && epoch == _loadEpoch) {
        String? notice;
        if (_pendingEmail != null &&
            value.user.email?.toLowerCase() == _pendingEmail!.toLowerCase()) {
          _pendingEmail = null;
          notice = 'email-updated';
        }
        emit(AccountReady(value, notice: notice));
      }
    } on Failure catch (error) {
      if (!isClosed && epoch == _loadEpoch) emit(AccountFailed(error.message));
    }
  }

  Future<void> _run(
    Future<void> Function() action,
    String notice, {
    bool deleted = false,
  }) async {
    final previous = state;
    if (previous is! AccountReady || previous.busy) return;
    _loadEpoch++;
    emit(AccountReady(previous.profile, busy: true));
    try {
      await action();
      if (!isClosed) {
        emit(
          deleted
              ? const AccountDeleted()
              : AccountReady(previous.profile, notice: notice),
        );
      }
    } on Failure catch (error) {
      if (!isClosed) emit(AccountReady(previous.profile, error: error.message));
    }
  }

  Future<void> save(String name, String avatarId) async {
    final previous = state;
    if (previous is! AccountReady || previous.busy) return;
    emit(AccountReady(previous.profile, busy: true));
    try {
      final profile = await repository.save(name, avatarId);
      if (!isClosed) {
        if (!profile.cloudSynced) {
          emit(AccountReady(previous.profile, error: 'cloud-sync-pending'));
          return;
        }
        emit(AccountReady(profile, notice: 'saved'));
      }
    } on Failure catch (error) {
      if (!isClosed) emit(AccountReady(previous.profile, error: error.message));
    }
  }

  Future<void> verify() =>
      _run(repository.sendVerification, 'verification-sent');
  Future<void> email(String value, String password) async {
    await _run(
      () => repository.changeEmail(value, password),
      'email-verification-sent',
    );
    if (isClosed) return;
    if (state case AccountReady(:final notice)
        when notice == 'email-verification-sent') {
      _pendingEmail = value.trim();
    }
  }
  Future<void> password(String current, String replacement) => _run(
    () => repository.changePassword(current, replacement),
    'password-changed',
  );
  Future<void> delete(String password) =>
      _run(() => repository.deleteAccount(password), 'deleted', deleted: true);
}
