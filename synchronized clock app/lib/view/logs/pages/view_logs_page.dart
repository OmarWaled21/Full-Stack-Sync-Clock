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
          style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<LogsCubit, LogsState>(
            builder: (context, state) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.today, color: AppColors.whiteColor),
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (selected != null) {
                        context.read<LogsCubit>().setFilterDate(selected);
                      }
                    },
                  ),
                  if (context.read<LogsCubit>().selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      onPressed: () {
                        context.read<LogsCubit>().setFilterDate(null);
                      },
                    ),
                ],
              );
            },
          ),
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

                // استخراج البطارية ودرجة الحرارة
                String? bat;
                String? temp;

                final batteryRegex = RegExp(r'(\d+)%');
                final tempRegex = RegExp(r'(\d+(\.\d+)?)\s?°?C');

                final batteryMatch = batteryRegex.firstMatch(log.message);
                if (batteryMatch != null) {
                  bat = batteryMatch.group(1);
                }

                final tempMatch = tempRegex.firstMatch(log.message);
                if (tempMatch != null) {
                  temp = tempMatch.group(1);
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.primaryColor),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStrings.getTranslatedErrorType(context, log.errorType)} ${log.source}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.getTranslatedErrorMessage(
                                  context,
                                  log.message,
                                  bat,
                                  temp,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
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
                        ),
                        if (log.errorType == 'Sensor Error')
                          const Icon(Icons.thermostat, color: AppColors.primaryColor)
                        else if (log.errorType == 'Low Battery')
                          const Icon(Icons.battery_alert, color: AppColors.primaryColor)
                        else if (log.errorType == 'RTC Error')
                          const Icon(Icons.timelapse_sharp, color: AppColors.primaryColor),
                      ],
                    ),
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
