part of 'add_device_cubit.dart';

sealed class AddDeviceState extends Equatable {
  const AddDeviceState();

  @override
  List<Object> get props => [];
}

final class AddDeviceInitial extends AddDeviceState {}

class AddDeviceLoading extends AddDeviceState {}

class AddDeviceLoaded extends AddDeviceState {
  final String deviceId;
  final SlaveClockModel device;
  const AddDeviceLoaded(this.device, this.deviceId);
}

class AddDeviceError extends AddDeviceState {
  final String message;
  const AddDeviceError(this.message);
}
