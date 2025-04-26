import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/common_repo.dart';

class HomeRepo {
  final Dio dio = CommonRepo.dio;

  Future<DateTime> getMasterClock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;
        final response = await dio.get(
          '/', // تأكد من أنك تستخدم الرابط الصحيح
          options: Options(
            headers: {'Authorization': 'Token $token'}, // Use the token here
          ),
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data != null && data is Map<String, dynamic>) {
            final results = data['results'];
            if (results != null && results['time_difference'] is int) {
              final int timeDifference = results['time_difference'];
              final DateTime masterClock = DateTime.now().add(Duration(seconds: timeDifference));

              return masterClock;
            }
          }
        }
      }
    } on DioException catch (e) {
      log('Get Slave Clock Error: ${e.response?.data ?? e.message}');
    }
    return DateTime.now();
  }

  Future<void> editMasterClock(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // نحسب الفرق بين الوقت الجديد والوقت الحالي
        final int timeDifference = time.difference(DateTime.now()).inSeconds;

        // التأكد من إرسال `device_id` في الـ URL مباشرة
        final response = await dio.post(
          '/master/update-time/', // استخدم `deviceId` في الرابط
          data: {'time_difference': timeDifference}, // إرسال البيانات في الـ body دون `device_id`
          options: Options(
            headers: {'Authorization': 'Token $token'}, // استخدم التوكن هنا
          ),
        );
        if (response.statusCode == 200) {
          debugPrint('Master Clock edited successfully.');
        }
      }
    } on DioException catch (e) {
      log('Edit Master Clock Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Edit Master Clock Error: $e');
    }
  }

  Future<List<SlaveClockModel>?> getAllSlaveClock() async {
    try {
      // Get the user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);

        // Get the access token from UserModel
        final token = user.token;
        final response = await dio.get(
          '/', // تأكد من أنك تستخدم الرابط الصحيح
          options: Options(
            headers: {'Authorization': 'Token $token'}, // Use the token here
          ),
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data != null && data is Map<String, dynamic>) {
            // Extract the devices list from results
            final results = data['results'];
            if (results != null && results['devices'] is List<dynamic>) {
              final List<dynamic> devices = results['devices']; // قائمة الأجهزة
              // تحويل البيانات إلى موديل SlaveClockModel
              return devices.map((e) => SlaveClockModel.fromJson(jsonEncode(e))).toList();
            } else {
              debugPrint('No devices found in the response.');
              return []; // العودة بقائمة فارغة إذا لم توجد أجهزة
            }
          }
        }
      }
    } on DioException catch (e) {
      log('Get Slave Clock Error: ${e.response?.data ?? e.message}');
    }
    return []; // العودة بقائمة فارغة في حال حدوث خطأ
  }

  Future<SlaveClockModel?> getSlaveClock(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;
        final response = await dio.get(
          '/device/$deviceId/', // تأكد من أنك تستخدم الرابط الصحيح
          options: Options(
            headers: {'Authorization': 'Token $token'}, // Use the token here
          ),
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data != null && data is Map<String, dynamic>) {
            final results = data['results'];
            if (results != null) {
              final slaveClock = SlaveClockModel.fromJson(jsonEncode(results));
              log("$slaveClock");
              return slaveClock;
            }
          }
        }
      }
    } on DioException catch (e) {
      log('Get Slave Clock Error: ${e.response?.data ?? e.message}');
    }
    return null;
  }

  Future<void> editSlaveClock(
    String deviceId,
    String name,
    double maxTempThreshold,
    double minTempThreshold,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // التأكد من إرسال `device_id` في الـ URL مباشرة
        final response = await dio.put(
          '/device/$deviceId/edit/', // استخدم `deviceId` في الرابط
          data: {
            'name': name,
            'temperature_max_threshold': maxTempThreshold,
            'temperature_min_threshold': minTempThreshold,
          }, // إرسال البيانات في الـ body دون `device_id`
          options: Options(
            headers: {'Authorization': 'Token $token'}, // استخدم التوكن هنا
          ),
        );
        if (response.statusCode == 200) {
          debugPrint('Slave Clock edited successfully.');
        }
      }
    } on DioException catch (e) {
      log('Edit Slave Clock Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Edit Slave Clock Error: $e');
    }
  }

  Future<void> deleteSlaveClock(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // التأكد من إرسال `device_id` في الـ URL مباشرة
        final response = await dio.delete(
          '/new_device/device/$deviceId/delete/', // استخدم `deviceId` في الرابط
          options: Options(
            headers: {'Authorization': 'Token $token'}, // استخدم التوكن هنا
          ),
        );
        if (response.statusCode == 200) {
          debugPrint('Slave Clock deleted successfully.');
        }
      }
    } on DioException catch (e) {
      log('Delete Slave Clock Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Delete Slave Clock Error: $e');
    }
  }
}
