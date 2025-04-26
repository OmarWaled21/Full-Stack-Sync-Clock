part of 'wifi_cubit.dart';

sealed class WifiState extends Equatable {
  const WifiState();

  @override
  List<Object> get props => [];
}

final class WifiInitial extends WifiState {}
