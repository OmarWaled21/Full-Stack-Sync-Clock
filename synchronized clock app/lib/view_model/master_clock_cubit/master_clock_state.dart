part of 'master_clock_cubit.dart';

@immutable
abstract class MasterClockState {}

class MasterClockInitial extends MasterClockState {}

class MasterClockUpdated extends MasterClockState {
  final DateTime currentTime;
  MasterClockUpdated(this.currentTime);
}

class MasterClockError extends MasterClockState {
  final String error;
  MasterClockError(this.error);
}
