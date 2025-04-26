import 'package:dio/dio.dart';
import 'package:synchronized_clock/core/strings.dart';

class CommonRepo {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppStrings.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
