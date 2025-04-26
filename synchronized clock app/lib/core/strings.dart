import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';

class AppStrings {
  static const String appName = 'Synchronized Clock';
  static const String baseUrl = 'http://192.168.1.3:8000/api';

  static const String logo = 'assets/tomatiki_logo.png';
  static const String logoDarkTheme = 'assets/tomatiki_logo_dark_theme.png';

  static String getTranslatedErrorType(BuildContext context, String errorType) {
    switch (errorType) {
      case 'RTC Error':
        return context.lang.rtcError;
      case 'Low Battery':
        return context.lang.lowBattery;
      case 'Sensor Error':
        return context.lang.sensorError;
      default:
        return errorType; // لو مش موجودة في الترجمة
    }
  }

  static String getTranslatedErrorMessage(
    BuildContext context,
    String message, [
    String? bat,
    String? temp,
  ]) {
    if (message.contains('Real-Time Clock')) {
      return context.lang.rtcErrorMessage;
    } else if (message.contains('Battery level')) {
      return context.lang.lowBatteryMessage(bat ?? '');
    } else if (message.contains('Temperature sensor')) {
      return context.lang.sensorErrorMessageWithTemp(temp ?? '');
    } else {
      return message;
    }
  }
}
