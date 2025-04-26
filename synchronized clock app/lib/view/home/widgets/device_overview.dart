import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';

class DeviceOverview extends StatelessWidget {
  final Map<String, int> stats;
  const DeviceOverview({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          context.lang.deviceOverview,
          style: TextStyle(fontSize: 18, color: AppColors.backgroundColor),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            _buildDeviceCard(context.lang.totalDevices, stats['total_devices']?.toString() ?? '0'),
            _buildDeviceCard(
              context.lang.greenOk,
              stats['green']?.toString() ?? '0',
              color: AppColors.successColor,
            ),
            _buildDeviceCard(
              context.lang.redError,
              stats['red']?.toString() ?? '0',
              color: AppColors.primaryColor,
            ),
            _buildDeviceCard(
              context.lang.grayDisconnected,
              stats['gray']?.toString() ?? '0',
              color: AppColors.darkGreyColor,
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget to create device status cards
  Widget _buildDeviceCard(String title, String value, {Color color = Colors.black}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 18, color: color)),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
