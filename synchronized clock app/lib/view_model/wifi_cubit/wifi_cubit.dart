import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'wifi_state.dart';

class WifiCubit extends Cubit<WifiState> {
  WifiCubit() : super(WifiInitial());
}
