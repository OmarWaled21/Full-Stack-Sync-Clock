import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/repositories/home_repo.dart';
import 'package:synchronized_clock/view_model/master_clock_cubit/master_clock_cubit.dart';

class TimeNow extends StatelessWidget {
  const TimeNow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MasterClockCubit(HomeRepo())..startClock(),
      child: BlocBuilder<MasterClockCubit, MasterClockState>(
        builder: (context, state) {
          if (state is MasterClockUpdated) {
            final currentTime = state.currentTime;
            return Column(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(currentTime),
                  style: TextStyle(fontSize: 20, color: AppColors.backgroundColor.withAlpha(150)),
                ),
                Text(
                  DateFormat('h:mm:ss a').format(currentTime),
                  style: TextStyle(fontSize: 30, color: AppColors.backgroundColor),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 20, color: AppColors.backgroundColor.withAlpha(150)),
                ),
                Text('--:--:--', style: TextStyle(fontSize: 30, color: AppColors.backgroundColor)),
              ],
            );
          }
        },
      ),
    );
  }
}
