part of 'accounts_cubit.dart';

@immutable
sealed class AccountsState {}

final class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

final class AccountsSuccess extends AccountsState {
  final List<UserModel> users;

  AccountsSuccess(this.users);
}

final class AccountsFailure extends AccountsState {
  final String message;

  AccountsFailure(this.message);
}
