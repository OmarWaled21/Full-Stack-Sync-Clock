import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
import 'package:synchronized_clock/view/home/pages/clock_details.dart';

class ClockCard extends StatelessWidget {
  final SlaveClockModel clock;
  const ClockCard({super.key, required this.clock});

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final isWide = width > 600;

    final titleSize = isWide ? 20.0 : 16.0;
    final infoSize = isWide ? 14.0 : 12.0;
    final iconSize = isWide ? 28.0 : 24.0;

    return GestureDetector(
      onTap: () {
        context.push(ClockDetails(clock: clock));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color:
                clock.status == 'green'
                    ? AppColors.successColor
                    : clock.status == 'red'
                    ? AppColors.primaryColor
                    : AppColors.darkGreyColor,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      clock.name ?? 'N/A',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleSize),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color:
                          clock.status == 'green'
                              ? AppColors.successColor
                              : clock.status == 'red'
                              ? AppColors.primaryColor
                              : AppColors.darkGreyColor,
                    ),
                    child: Text(clock.status, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${clock.deviceId}',
                style: TextStyle(fontSize: infoSize, color: AppColors.darkGreyColor),
              ),
              const Spacer(),
              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfo(
                    icon: Icons.thermostat,
                    label: '${clock.temperature}°C',
                    iconSize: iconSize,
                    fontSize: infoSize,
                  ),
                  _buildInfo(
                    icon: Icons.wifi,
                    label: '${clock.wifiStrength}%',
                    iconSize: iconSize,
                    fontSize: infoSize,
                  ),
                  _buildInfo(
                    icon: Icons.battery_5_bar_rounded,
                    label: '${clock.batteryLevel}%',
                    iconSize: iconSize,
                    fontSize: infoSize,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo({
    required IconData icon,
    required String label,
    required double iconSize,
    required double fontSize,
  }) {
    return Column(
      children: [Icon(icon, size: iconSize), Text(label, style: TextStyle(fontSize: fontSize))],
    );
  }
}
