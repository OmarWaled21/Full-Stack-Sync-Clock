import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/common_repo.dart';

class SendMessagesRepo {
  final Dio dio = CommonRepo.dio;

  Future<void> switchActive({
    required bool whatsappIsActive,
    required bool gmailIsActive,
    required bool smsIsActive,
    required String groupUrl,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        await dio.post(
          '/logs/update-group-info/',
          options: Options(headers: {'Authorization': 'Token $token'}),
          data: {
            'token': token,
            'whatsapp_is_active': whatsappIsActive,
            'gmail_is_active': gmailIsActive,
            'sms_is_active': smsIsActive,
            'group_url': groupUrl,
            'email': email,
            'phone_number': phoneNumber,
          },
        );
      }
    } on DioException catch (e) {
      log('switchActive Error: ${e.response?.data ?? e.message}');
    }
  }
}
