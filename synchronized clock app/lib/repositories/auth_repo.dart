import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/common_repo.dart';

class AuthRepo {
  final Dio dio = CommonRepo.dio;

  // Login function
  Future<UserModel?> login({required String username, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login/',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        // Deserialize user data from the response
        final data = response.data;
        final user = UserModel.fromJson({...data['user'], 'tokens': data['tokens']});
        return user;
      }
    } on DioException catch (e) {
      log('Login Error: ${e.response?.data ?? e.message}');
    }
    return null;
  }

  // Logout function
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout/');
    } on DioException catch (e) {
      log('Logout Error: ${e.response?.data ?? e.message}');
    }
  }

  // Forgot Password function
  Future<void> forgotPassword({required String email}) async {
    try {
      await dio.post('/auth/password_reset/', data: {'email': email});
    } on DioException catch (e) {
      log('Forgot Password Error: ${e.response?.data ?? e.message}');
    }
  }
}
