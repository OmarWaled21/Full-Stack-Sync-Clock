import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:synchronized_clock/repositories/bluetooth_repo.dart';

part 'bluetooth_state.dart';

class BluetoothCubit extends Cubit<BluetoothConfState> {
  final BluetoothRepo _bluetoothManager = BluetoothRepo();

  BluetoothCubit() : super(BluetoothInitial());

  Future<void> initializeBluetooth() async {
    emit(BluetoothLoading());
    await _bluetoothManager.requestPermissions();
    await scanDevices();
  }

  Future<void> scanDevices() async {
    emit(BluetoothLoading());
    await _bluetoothManager.scanDevices();
    final devices = _bluetoothManager.devices;
    if (isClosed) return;
    emit(BluetoothDevicesLoaded(devices));
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    emit(BluetoothLoading());
    try {
      await _bluetoothManager.connectToDevice(device);
      emit(BluetoothConnected(device));
    } catch (e) {
      emit(BluetoothError('Failed to connect'));
    }
  }

  Future<void> sendWiFiCredentials(
    BluetoothDevice device,
    String ssid,
    String password,
    String token,
  ) async {
    emit(BluetoothLoading());
    try {
      await _bluetoothManager.sendWiFiCredentials(ssid, password, token);
      // بعد الإرسال، استقبل device_id
      final deviceId = await _bluetoothManager.listenForDeviceId();
      debugPrint('deviceId: $deviceId');
      emit(BluetoothWiFiCredentialsSent(device, deviceId));
    } catch (e) {
      emit(BluetoothError('Failed to send WiFi credentials'));
    }
  }
}
