import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/accounts_repo.dart';

part 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountsRepo accountsRepo;

  AccountsCubit(this.accountsRepo) : super(AccountsInitial());

  Future<void> fetchUsers() async {
    emit(AccountsLoading());
    try {
      final users = await accountsRepo.getAllUsers();
      emit(AccountsSuccess(users));
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }

  Future<void> editUserRole(int id, String role, String username) async {
    emit(AccountsLoading());
    try {
      await accountsRepo.editUserRole(id, role, username);
      emit(AccountsSuccess(await accountsRepo.getAllUsers()));
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }

  Future<void> deleteUser(int id) async {
    emit(AccountsLoading());
    try {
      await accountsRepo.deleteUser(id);
      emit(AccountsSuccess(await accountsRepo.getAllUsers()));
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }

  Future<void> addUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String rule,
    required String password,
  }) async {
    emit(AccountsLoading());
    try {
      await accountsRepo.addUser(firstName, lastName, username, email, rule, password);
      emit(AccountsSuccess(await accountsRepo.getAllUsers()));
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }
}
