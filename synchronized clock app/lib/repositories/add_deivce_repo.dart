import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/common_repo.dart';

class AddDeivceRepo {
  final dio = CommonRepo.dio;

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
}
