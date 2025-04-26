import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/home/pages/clock_details.dart';

class ClockCard extends StatelessWidget {
  final SlaveClockModel clock;
  const ClockCard({super.key, required this.clock});

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    clock.name ?? 'N/A',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color:
                          clock.status == 'green'
                              ? AppColors.successColor
                              : clock.status == 'red'
                              ? AppColors.primaryColor
                              : AppColors.darkGreyColor,
                    ),
                    child: Center(child: Text(clock.status, style: TextStyle(color: Colors.white))),
                  ),
                ],
              ),
              Text('ID: ${clock.deviceId}', style: TextStyle()),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [Icon(Icons.thermostat), Text('${clock.temperature}°C')]),
                  Column(children: [Icon(Icons.wifi), Text('${clock.wifiStrength}%')]),
                  Column(
                    children: [Icon(Icons.battery_5_bar_rounded), Text('${clock.batteryLevel}%')],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
