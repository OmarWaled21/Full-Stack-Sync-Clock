import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view/home/pages/edit_slave_clock.dart';
import 'package:synchronized_clock/view/home/widgets/time_now.dart';
import 'package:synchronized_clock/view_model/home_cubit/home_cubit.dart';

class ClockDetails extends StatelessWidget {
  final SlaveClockModel clock;
  const ClockDetails({super.key, required this.clock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.greyColor),
        ),
        title: Text(
          clock.name ?? 'N/A',
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        actions: [
          TextButton(
            onPressed: () {
              context.push(EditClock(clock: clock));
            },
            child: Text(context.lang.edit, style: TextStyle(color: AppColors.whiteColor)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 0),
        child: ListView(
          children: [
            TimeNow(),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${context.lang.version} ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(left: 0),
                  child: Text('(${clock.firmwareVersion})', style: TextStyle(fontSize: 14)),
                ),
                Expanded(child: Divider()),
                if (clock.firmwareUrl != '' && clock.firmwareUrl != null)
                  Container(
                    padding: const EdgeInsets.all(8.0).copyWith(right: 0),
                    width: 110,
                    height: 50,
                    child: CustomButton(
                      color: AppColors.transparentColor,
                      borderColor: AppColors.blueColor,
                      text: context.lang.update,
                      textStyle: TextStyle(fontSize: 14),
                      onPressed: () {},
                    ),
                  ),
              ],
            ),
            // Clock Status
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(left: 0),
                  child: Text(
                    context.lang.clockStatus,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(context.lang.status, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  clock.status == 'green'
                      ? context.lang.good
                      : clock.status == 'red'
                      ? context.lang.error
                      : context.lang.offline,
                ),
                leading: Icon(
                  Icons.access_alarm,
                  color:
                      clock.status == 'green'
                          ? AppColors.successColor
                          : clock.status == 'red'
                          ? AppColors.primaryColor
                          : AppColors.darkGreyColor,
                ),
              ),
            ),

            // Temperature Info
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  context.lang.temperature,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${clock.temperature} °C'),
                leading: Icon(
                  Icons.thermostat_rounded,
                  color:
                      clock.sensorError == true ? AppColors.primaryColor : AppColors.successColor,
                ),
              ),
            ),

            // Battery Level
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  context.lang.batteryLevel,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${clock.batteryLevel} %'),
                leading: Icon(
                  Icons.battery_full,
                  color: clock.lowBattery == true ? AppColors.primaryColor : AppColors.successColor,
                ),
              ),
            ),

            // Last Update
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(context.lang.lastUpdate, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd hh:mm a').format(clock.lastUpdate ?? DateTime.now()),
                ),
                leading: Icon(
                  Icons.update,
                  color: clock.rtcError == true ? AppColors.primaryColor : AppColors.successColor,
                ),
              ),
            ),
            CustomButton(
              color: AppColors.primaryColor,
              borderColor: AppColors.whiteColor,
              text: context.lang.deleteClock,
              onPressed: () async {
                // حوار تأكيد الحذف
                bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(context.lang.deleteClock),
                        content: Text(context.lang.confirmDeleteClock),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(context.lang.no),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(context.lang.yes),
                          ),
                        ],
                      ),
                );

                if (confirmDelete == true) {
                  print(clock.deviceId);
                  context.read<HomeCubit>().deleteSlaveClock(deviceId: clock.deviceId);
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
