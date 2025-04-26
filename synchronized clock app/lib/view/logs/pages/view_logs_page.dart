import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/core/strings.dart';
import 'package:synchronized_clock/repositories/logs_repo.dart';
import 'package:synchronized_clock/view_model/logs_cubit/logs_cubit.dart';

class ViewLogsPage extends StatelessWidget {
  const ViewLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        title: Text(
          context.lang.logs,
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => LogsRepo().downloadLogs(),
            icon: const Icon(Icons.download, color: AppColors.whiteColor),
          ),
        ],
      ),
      body: BlocBuilder<LogsCubit, LogsState>(
        builder: (context, state) {
          if (state is LogsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LogsError) {
            return Center(child: Text('${context.lang.error}: ${state.message}'));
          } else if (state is LogsLoaded) {
            final logs = state.logs;
            if (logs.isEmpty) {
              return Center(child: Text(context.lang.NoLogsAvailable));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];

                // استخراج البطارية ودرجة الحرارة من الرسالة إذا كانت موجودة
                String? bat;
                String? temp;

                final batteryRegex = RegExp(r'(\d+)%'); // لاستخراج نسبة البطارية
                final tempRegex = RegExp(r'(\d+(\.\d+)?)\s?°?C'); // لاستخراج درجة الحرارة

                final batteryMatch = batteryRegex.firstMatch(log.message);
                if (batteryMatch != null) {
                  bat = batteryMatch.group(1); // استخدم قيمة البطارية
                }

                final tempMatch = tempRegex.firstMatch(log.message);
                if (tempMatch != null) {
                  temp = tempMatch.group(1); // استخدم قيمة درجة الحرارة
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.primaryColor),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.error_outline, color: Colors.redAccent),
                    title: Text(
                      '${AppStrings.getTranslatedErrorType(context, log.errorType)} ${log.source}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.getTranslatedErrorMessage(context, log.message, bat, temp)),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            DateFormat('yyyy-MM-dd h:mm a').format(log.timeStamp!),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing:
                        log.errorType == 'Sensor Error'
                            ? const Icon(Icons.thermostat, color: AppColors.primaryColor)
                            : log.errorType == 'Low Battery'
                            ? const Icon(Icons.battery_alert, color: AppColors.primaryColor)
                            : log.errorType == 'RTC Error'
                            ? const Icon(Icons.timelapse_sharp, color: AppColors.primaryColor)
                            : null,
                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
