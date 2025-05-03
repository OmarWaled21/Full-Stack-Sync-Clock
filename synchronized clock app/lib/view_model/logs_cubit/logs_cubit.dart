import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized_clock/core/messaging/notification_service.dart';
import 'package:synchronized_clock/model/logs_model.dart';
import 'package:synchronized_clock/repositories/logs_repo.dart';

part 'logs_state.dart';

class LogsCubit extends Cubit<LogsState> {
  final LogsRepo logsRepo;
  DateTime? selectedDate;

  LogsCubit(this.logsRepo) : super(LogsInitial());

  Future<void> fetchLogs() async {
    emit(LogsLoading());
    try {
      final oldLogs = await _getStoredLogs();
      final logs = await logsRepo.getLogs();

      emit(LogsLoaded(logs));

      final isThereNewLogs = logs.length > oldLogs.length;
      if (isThereNewLogs) {
        final newLog = logs.firstWhere(
          (log) => !oldLogs.any((old) => old.timeStamp == log.timeStamp),
          orElse: () => logs.first,
        );

        await NotificationService.showNotification(
          title: '📥 New Log',
          body: '${newLog.source} - ${newLog.message}',
        );
      }

      // 🟢 Save always
      await _saveLogs(logs);
    } catch (e) {
      emit(LogsError(e.toString()));
    }
  }

  Future<void> downloadLogs() async {
    try {
      await logsRepo.downloadLogs();
      final logs = await logsRepo.getLogs();
      emit(LogsLoaded(logs));
    } catch (e) {
      emit(LogsDownloadError('Failed to download PDF: $e'));
    }
  }

  void setFilterDate(DateTime? date) async {
    selectedDate = date;
    final logs = await logsRepo.getLogs();
    emit(
      LogsLoaded(
        logs.where((log) {
          if (date == null) return true;
          final logDate = DateTime(log.timeStamp!.year, log.timeStamp!.month, log.timeStamp!.day);
          final filterDate = DateTime(date.year, date.month, date.day);
          return logDate == filterDate;
        }).toList(),
      ),
    );
  }

  // Save logs to SharedPreferences
  Future<void> _saveLogs(List<LogsModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    // تحويل السجلات إلى قائمة من JSON Strings
    final logStrings = logs.map((log) => log.toJson()).toList();
    // تخزينها في SharedPreferences
    await prefs.setStringList('logs', logStrings);
  }

  // Get stored logs from SharedPreferences
  Future<List<LogsModel>> _getStoredLogs() async {
    final prefs = await SharedPreferences.getInstance();
    // استرجاع السجلات من SharedPreferences
    final storedLogs = prefs.getStringList('logs') ?? [];
    // تحويل JSON Strings إلى LogsModel
    return storedLogs.map((logString) {
      return LogsModel.fromJson(logString);
    }).toList();
  }
}
