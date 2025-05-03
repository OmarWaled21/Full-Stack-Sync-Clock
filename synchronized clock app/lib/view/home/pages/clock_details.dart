import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.greyColor),
        ),
        title: Text(
          clock.name ?? 'N/A',
          style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        actions: [
          TextButton(
            onPressed: () {
              context.push(EditClock(clock: clock));
            },
            child: Text(context.lang.edit, style: const TextStyle(color: AppColors.whiteColor)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.widthPercent(0.04),
          vertical: context.heightPercent(0.01),
        ).copyWith(bottom: 0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const TimeNow(),
                    SizedBox(height: context.heightPercent(0.01)),
                    Row(
                      children: [
                        Text(
                          '${context.lang.version} ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: context.widthPercent(0.045),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0, right: context.widthPercent(0.01)),
                          child: Text(
                            '(${clock.firmwareVersion})',
                            style: TextStyle(fontSize: context.widthPercent(0.035)),
                          ),
                        ),
                        const Expanded(child: Divider()),
                        if (clock.firmwareUrl != '' && clock.firmwareUrl != null)
                          Container(
                            padding: EdgeInsets.only(left: context.widthPercent(0.01)),
                            width: context.widthPercent(0.25),
                            height: context.heightPercent(0.06),
                            child: CustomButton(
                              color: AppColors.transparentColor,
                              borderColor: AppColors.blueColor,
                              text: context.lang.update,
                              textStyle: TextStyle(fontSize: context.widthPercent(0.03)),
                              onPressed: () {},
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: context.heightPercent(0.015)),
                    _buildSectionTitle(context.lang.clockStatus, context),
                    _buildStatusCard(
                      context.lang.status,
                      _getStatusText(context),
                      Icons.access_alarm,
                      _getStatusColor(),
                      context,
                    ),
                    _buildStatusCard(
                      context.lang.temperature,
                      '${clock.temperature} °C',
                      Icons.thermostat_rounded,
                      clock.sensorError == true ? AppColors.primaryColor : AppColors.successColor,
                      context,
                    ),
                    _buildStatusCard(
                      context.lang.batteryLevel,
                      '${clock.batteryLevel} %',
                      Icons.battery_full,
                      clock.lowBattery == true ? AppColors.primaryColor : AppColors.successColor,
                      context,
                    ),
                    _buildStatusCard(
                      context.lang.lastUpdate,
                      DateFormat('yyyy-MM-dd hh:mm a').format(clock.lastUpdate ?? DateTime.now()),
                      Icons.update,
                      clock.rtcError == true ? AppColors.primaryColor : AppColors.successColor,
                      context,
                    ),
                    SizedBox(height: context.heightPercent(0.02)),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: CustomButton(
                color: AppColors.primaryColor,
                borderColor: AppColors.whiteColor,
                text: context.lang.deleteClock,
                onPressed: () async {
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
                    context.read<HomeCubit>().deleteSlaveClock(deviceId: clock.deviceId);
                    context.pop();
                  }
                },
              ),
            ),
            SizedBox(height: context.heightPercent(0.02)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: context.widthPercent(0.02)),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.widthPercent(0.045)),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: context.heightPercent(0.015)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        leading: Icon(icon, color: iconColor),
      ),
    );
  }

  String _getStatusText(BuildContext context) {
    if (clock.status == 'green') return context.lang.good;
    if (clock.status == 'red') return context.lang.error;
    return context.lang.offline;
  }

  Color _getStatusColor() {
    if (clock.status == 'green') return AppColors.successColor;
    if (clock.status == 'red') return AppColors.primaryColor;
    return AppColors.darkGreyColor;
  }
}
