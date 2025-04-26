import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/auth_repo.dart';
import 'package:flutter/material.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  UserModel? currentUser;

  AuthCubit(this.authRepo) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepo.login(username: username, password: password);
      if (user != null) {
        currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('user', jsonEncode(user.toJson()));
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('Invalid username or password'));
      }
    } catch (e) {
      emit(AuthFailure('An error occurred'));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await authRepo.forgotPassword(email: email);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure('Password reset failed'));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('user');
    currentUser = null;
    emit(AuthInitial());
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        currentUser = UserModel.fromJson(userMap);
        emit(AuthSuccess());
      } else {
        emit(AuthLogin());
      }
    } else {
      emit(AuthLogin());
    }
  }
}
