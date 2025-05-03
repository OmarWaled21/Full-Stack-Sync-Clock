import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/repositories/home_repo.dart';
import 'package:flutter/material.dart';

part 'master_clock_state.dart';

class MasterClockCubit extends Cubit<MasterClockState> {
  final HomeRepo homeRepo;
  Timer? _timer;
  Timer? _refreshTimer; // لإعادة التحديث كل 5 ثواني
  DateTime? masterClockTime;
  DateTime? startedAt; // لحظة الاستلام
  DateTime? lastFetchedTime; // لحفظ آخر وقت تم جلبه من السيرفر

  MasterClockCubit(this.homeRepo) : super(MasterClockInitial());

  Future<void> getMasterClock() async {
    try {
      final fetchedTime = await homeRepo.getMasterClock();

      if (isClosed) return;

      if (lastFetchedTime == null || !fetchedTime.isAtSameMomentAs(lastFetchedTime!)) {
        masterClockTime = fetchedTime;
        startedAt = DateTime.now(); // بداية الحساب
        lastFetchedTime = fetchedTime; // حفظ آخر وقت تم جلبه
        emit(MasterClockUpdated(getCurrentTime()));
      }
    } catch (e) {
      debugPrint('Error fetching master clock: $e');
      emit(MasterClockError(e.toString()));
    }
  }

  Future<void> editSlaveClock({required DateTime time}) async {
    try {
      await homeRepo.editMasterClock(time);
      getMasterClock();
    } catch (e) {
      debugPrint('Error in Cubit: $e');
      if (!isClosed) emit(MasterClockError(e.toString()));
    }
  }

  void startClock() async {
    await getMasterClock();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      emit(MasterClockUpdated(getCurrentTime()));
    });

    // تحديث الساعة كل 5 ثواني للتحقق من التعديلات
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      getMasterClock();
    });
  }

  DateTime getCurrentTime() {
    if (masterClockTime == null || startedAt == null) return DateTime.now();
    final durationPassed = DateTime.now().difference(startedAt!);
    return masterClockTime!.add(durationPassed);
  }

  void stopClock() {
    _timer?.cancel();
    _refreshTimer?.cancel();
  }

  @override
  Future<void> close() {
    stopClock();
    return super.close();
  }
}
