import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/common_repo.dart';

class AccountsRepo {
  final dio = CommonRepo.dio;

  Future<List<UserModel>> getAllUsers() async {
    try {
      // Get the user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);

        final token = user.token;

        final response = await dio.get(
          '/users/', // ← عدّل الرابط حسب الـ endpoint الحقيقي
          options: Options(headers: {'Authorization': 'Token $token'}),
        );

        if (response.statusCode == 200 && response.data is List) {
          final List<dynamic> usersJson = response.data;
          // تحويل كل عنصر في القائمة إلى UserModel
          return usersJson.map((user) => UserModel.fromJson(user as Map<String, dynamic>)).toList();
        } else {
          debugPrint('Unexpected response: ${response.data}');
        }
      }
    } on DioException catch (e) {
      log('Get All Users Error: ${e.response?.data ?? e.message}');
    }
    return [];
  }

  Future<void> editUserRole(int id, String role, String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // التأكد من إرسال `device_id` في الـ URL مباشرة
        final response = await dio.put(
          '/users/$id/edit/', // استخدم `deviceId` في الرابط
          data: {'rule': role, 'username': username}, // إرسال البيانات في الـ body دون `device_id`
          options: Options(
            headers: {'Authorization': 'Token $token'}, // استخدم التوكن هنا
          ),
        );
        if (response.statusCode == 200) {
          debugPrint('User edited successfully.');
        }
      }
    } on DioException catch (e) {
      log('Edit User Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Edit User Error: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // التأكد من إرسال `device_id` في الـ URL مباشرة
        final response = await dio.delete(
          '/users/$id/delete/', // استخدم `deviceId` في الرابط
          options: Options(
            headers: {'Authorization': 'Token $token'}, // استخدم التوكن هنا
          ),
        );
        if (response.statusCode == 200) {
          debugPrint('User deleted successfully.');
        }
      }
    } on DioException catch (e) {
      log('Delete User Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Delete User Error: $e');
    }
  }

  Future<void> addUser(
    String firstName,
    String lastName,
    String username,
    String email,
    String rule,
    String password,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // التأكد من إرسال `device_id` في الـ URL مباشرة
        final response = await dio.post(
          '/users/add/', // استخدم `deviceId` في الرابط
          options: Options(
            headers: {'Authorization': 'Token $token'}, // استخدم التوكن هنا
          ),
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'username': username,
            'email': email,
            'rule': rule,
            'password': password,
          },
        );
        if (response.statusCode == 200) {
          debugPrint('User added successfully.');
        }
      }
    } on DioException catch (e) {
      log('Add User Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Add User Error: $e');
    }
  }
}
