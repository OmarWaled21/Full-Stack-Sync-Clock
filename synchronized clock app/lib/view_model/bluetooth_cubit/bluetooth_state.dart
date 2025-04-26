part of 'bluetooth_cubit.dart';

@immutable
abstract class BluetoothConfState {}

class BluetoothInitial extends BluetoothConfState {}

class BluetoothLoading extends BluetoothConfState {}

class BluetoothDevicesLoaded extends BluetoothConfState {
  final List<BluetoothDevice> devices;

  BluetoothDevicesLoaded(this.devices);
}

class BluetoothConnected extends BluetoothConfState {
  final BluetoothDevice device;

  BluetoothConnected(this.device);
}

class BluetoothWiFiCredentialsSent extends BluetoothConfState {
  final BluetoothDevice device;
  final String deviceId;

  BluetoothWiFiCredentialsSent(this.device, this.deviceId);
}

class BluetoothError extends BluetoothConfState {
  final String message;

  BluetoothError(this.message);
}
