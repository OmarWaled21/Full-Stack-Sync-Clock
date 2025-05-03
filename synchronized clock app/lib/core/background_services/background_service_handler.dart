import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized_clock/core/messaging/notification_service.dart';
import 'package:synchronized_clock/model/logs_model.dart';
import 'package:synchronized_clock/repositories/home_repo.dart';
import 'package:synchronized_clock/repositories/logs_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the background service initialization and logic
@pragma('vm:entry-point')
class BackgroundServiceHandler {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  /// Initializes the background service
  static Future<void> initialize() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: false,
      ),
      iosConfiguration: IosConfiguration(onForeground: _onStart, onBackground: _onIosBackground),
    );
    _service.startService();
  }

  /// Entry point for background tasks
  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) {
    DartPluginRegistrant.ensureInitialized();

    service.on("stopService").listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      debugPrint("⏳ Checking logs in the background...");
      await checkNewLogs();
    });

    Timer.periodic(const Duration(days: 180), (timer) async {
      debugPrint("⏳ Updating server time in background...");
      await checkCalibration();
    });
  }

  /// Background execution logic (iOS)
  @pragma('vm:entry-point')
  static bool _onIosBackground(ServiceInstance service) {
    return true;
  }

  /// Fetches real devices and updates their server time
  static Future<void> checkCalibration() async {
    try {
      final slaveClocks = await HomeRepo().getAllSlaveClock();
      if (slaveClocks == null) return;
      for (var clock in slaveClocks) {
        if (clock.lastCalibration != null) {
          final difference = DateTime.now().difference(clock.lastCalibration!).inDays;

          if (difference >= 180) {
            await NotificationService.showNotification(
              title: '🔧 Calibration Needed',
              body: 'Device ${clock.name} requires calibration.',
            );
          }
        }
      }

      debugPrint('✅ Calibration check completed');
    } catch (e) {
      debugPrint('❌ Error checking calibration: $e');
    }
  }

  /// Function to check for new logs and notify
  static Future<void> checkNewLogs() async {
    try {
      final storedLogs = await _getStoredLogs();
      final newLogs = await LogsRepo().getLogs();

      final isThereNewLogs = newLogs.length > storedLogs.length;

      if (isThereNewLogs) {
        final newLog = newLogs.firstWhere(
          (log) => !storedLogs.any((old) => old.timeStamp == log.timeStamp),
          orElse: () => newLogs.first,
        );

        await NotificationService.showNotification(
          title: '📥 New Log',
          body: '${newLog.source} - ${newLog.message}',
        );
      }

      // 🟢 Save logs regardless (even if no notification was shown)
      await _saveLogs(newLogs);
    } catch (e) {
      debugPrint('❌ Error checking logs in the background: $e');
    }
  }

  // Save logs to SharedPreferences
  static Future<void> _saveLogs(List<LogsModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logStrings = logs.map((log) => log.toJson()).toList();
    await prefs.setStringList('logs', logStrings);
  }

  // Get stored logs from SharedPreferences
  static Future<List<LogsModel>> _getStoredLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLogs = prefs.getStringList('logs') ?? [];
    return storedLogs.map((logString) => LogsModel.fromJson(logString)).toList();
  }
}
