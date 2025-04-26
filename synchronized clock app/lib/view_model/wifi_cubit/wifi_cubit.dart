import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'wifi_state.dart';

class WifiCubit extends Cubit<WifiState> {
  WifiCubit() : super(WifiInitial());
}
