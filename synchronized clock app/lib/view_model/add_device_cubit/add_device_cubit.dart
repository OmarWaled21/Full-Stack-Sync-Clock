import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/repositories/add_deivce_repo.dart';

part 'add_device_state.dart';

class AddDeviceCubit extends Cubit<AddDeviceState> {
  final AddDeivceRepo _repo;
  AddDeviceCubit(this._repo) : super(AddDeviceInitial());

  Future<void> fetchDeviceByIdWithRetry(
    String deviceId, {
    int retries = 10,
    Duration delay = const Duration(seconds: 2),
  }) async {
    emit(AddDeviceLoading());
    for (int attempt = 0; attempt < retries; attempt++) {
      final device = await _repo.getSlaveClock(deviceId);
      debugPrint('Fetching device with id: $deviceId');
      if (device != null) {
        emit(AddDeviceLoaded(device, deviceId));
        return;
      }
      await Future.delayed(delay);
    }
    if (isClosed) return;
    emit(const AddDeviceError("فشل في العثور على الجهاز بعد عدة محاولات."));
  }
}
