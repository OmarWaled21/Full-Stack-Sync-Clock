import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/model/logs_model.dart';
import 'package:synchronized_clock/model/user_model.dart';
import 'package:synchronized_clock/repositories/common_repo.dart';

class LogsRepo {
  final dio = CommonRepo.dio;

  Future<List<LogsModel>> getLogs() async {
    try {
      // Get the user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);

        final token = user.token;

        final response = await dio.get(
          '/logs/', // ← عدّل الرابط حسب الـ endpoint الحقيقي
          options: Options(headers: {'Authorization': 'Token $token'}),
        );

        if (response.statusCode == 200 && response.data is List) {
          final List<dynamic> logsJson = response.data;
          // تحويل كل عنصر في القائمة إلى UserModel
          return logsJson.map((logs) => LogsModel.fromMap(logs as Map<String, dynamic>)).toList();
        } else {
          debugPrint('Unexpected response: ${response.data}');
        }
      }
    } on DioException catch (e) {
      log('Get All Users Error: ${e.response?.data ?? e.message}');
    }
    return [];
  }

  Future<void> downloadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        final token = user.token;

        // Ask for permission (important for Android)
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          log("Storage permission not granted");
          return;
        }

        // Get the external storage directory (the Downloads folder or similar)
        final dir = await getExternalStorageDirectory();

        // Define folder path in external storage (you can customize this path)
        final folderPath = '${dir?.path}/Synchronies Clocks';

        // Check if the folder exists, and create it if not
        final folder = Directory(folderPath);
        if (!await folder.exists()) {
          await folder.create(recursive: true);
          log('Folder "Synchronies Clocks" created at: $folderPath');
        }

        // Define file path in the new folder
        final filePath = '$folderPath/device_logs.pdf';

        // Download the PDF file
        final response = await dio.get(
          '/logs/download/pdf/',
          options: Options(
            responseType: ResponseType.bytes, // Important for binary data
            headers: {'Authorization': 'Token $token'},
          ),
        );

        // Save the PDF file to the folder
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        log('PDF downloaded to: $filePath');

        // Open the file (optional)
        await OpenFile.open(filePath);
      }
    } on DioException catch (e) {
      log('Download Logs Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Download Logs Error: $e');
    }
  }
}
