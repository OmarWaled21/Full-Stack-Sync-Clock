part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeSuccess extends HomeState {
  final List<SlaveClockModel> slavesClocks;
  HomeSuccess(this.slavesClocks);
}

final class HomeFailure extends HomeState {
  final String error;
  HomeFailure(this.error);
}

class HomeDeviceDetailsSuccess extends HomeState {
  final SlaveClockModel device;
  HomeDeviceDetailsSuccess(this.device);
}
