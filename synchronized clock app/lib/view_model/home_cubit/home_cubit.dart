import 'dart:async'; // <-- مهم للـ Timer
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/messaging/notification_service.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/repositories/home_repo.dart';
import 'package:flutter/material.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;
  HomeCubit(this.homeRepo) : super(HomeInitial());

  // Device stats
  int totalDevices = 0;
  int greenCount = 0;
  int redCount = 0;
  int grayCount = 0;

  Timer? _timer; // <-- مؤقت داخلي

  Future<void> getAllSlaveClock() async {
    try {
      final slaveClocks = await homeRepo.getAllSlaveClock();
      print('Fetched Slave Clocks: $slaveClocks');
      if (slaveClocks != null) {
        for (var clock in slaveClocks) {
          if (clock.lastCalibration != null) {
            checkCalibrationReminder(clock.lastCalibration!);
          } else {
            // ممكن تعتبره محتاج calibration لو مفيش تاريخ
            print('${clock.deviceId} has no calibration date.');
          }
        }

        totalDevices = slaveClocks.length;
        greenCount = slaveClocks.where((clock) => clock.status == 'green').length;
        redCount = slaveClocks.where((clock) => clock.status == 'red').length;
        grayCount = slaveClocks.where((clock) => clock.status == 'gray').length;

        emit(HomeSuccess(slaveClocks));
      } else {
        totalDevices = 0;
        greenCount = 0;
        redCount = 0;
        grayCount = 0;

        emit(HomeSuccess([]));
      }
    } catch (e) {
      print('Error in Cubit: $e');
      emit(HomeFailure(e.toString()));
    }
  }

  Future<void> editSlaveClock({
    required String deviceId,
    required String name,
    required double maxTempThreshold,
    required double minTempThreshold,
  }) async {
    try {
      await homeRepo.editSlaveClock(deviceId, name, maxTempThreshold, minTempThreshold);
      getAllSlaveClock();
    } catch (e) {
      print('Error in Cubit: $e');
      emit(HomeFailure(e.toString()));
    }
  }

  Future<void> deleteSlaveClock({required String deviceId}) async {
    try {
      await homeRepo.deleteSlaveClock(deviceId);
      getAllSlaveClock();
    } catch (e) {
      print('Error in Cubit: $e');
      emit(HomeFailure(e.toString()));
    }
  }

  Map<String, int> getDeviceStats() {
    return {'total_devices': totalDevices, 'green': greenCount, 'red': redCount, 'gray': grayCount};
  }

  void startAutoFetch() {
    // أول استدعاء فورًا
    getAllSlaveClock();
    // ثم كل دقيقة
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      getAllSlaveClock();
    });
  }

  void stopAutoFetch() {
    _timer?.cancel();
  }

  void checkCalibrationReminder(DateTime lastCalibration) async {
    final referenceDate = lastCalibration;
    final now = DateTime.now();
    final difference = now.difference(referenceDate).inDays;

    if (difference >= 180) {
      await NotificationService.showNotification(
        title: '🔧 Calibration Needed',
        body: 'Devices requires calibration.',
      );
      print('Calibration Reminder');
    }
  }

  @override
  Future<void> close() {
    stopAutoFetch(); // تأكد من إيقاف المؤقت عند إنهاء الكيوبت
    return super.close();
  }
}
