import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:intl/intl.dart';
import 'package:synchronized_clock/core/helper/show_snack_bar.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view_model/master_clock_cubit/master_clock_cubit.dart'; // لإظهار التاريخ والوقت بطريقة معينة

class EditMasterClock extends StatefulWidget {
  const EditMasterClock({super.key});

  @override
  State<EditMasterClock> createState() => _EditMasterClockState();
}

class _EditMasterClockState extends State<EditMasterClock> {
  DateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
        ),
        title: Text(
          context.lang.editMasterClock,
          style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: BlocBuilder<MasterClockCubit, MasterClockState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.lang.selectDateAndTime}:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // حقل لاختيار التاريخ والوقت
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkGreyColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? context.lang.noSelectedDate
                              : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          onPressed: _selectDateTime,
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: context.screenWidth * 0.4,
                      child: CustomButton(
                        color: AppColors.transparentColor,
                        borderColor: AppColors.blueColor,
                        text: context.lang.setNow,
                        onPressed: _setNow,
                      ),
                    ),
                    SizedBox(
                      width: context.screenWidth * 0.4,
                      child: CustomButton(
                        color: AppColors.transparentColor,
                        borderColor: AppColors.darkGreyColor,
                        text: context.lang.save,
                        onPressed: _saveTime,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // دالة لاختيار التاريخ والوقت
  Future<void> _selectDateTime() async {
    DateTime initialDate = _selectedDateTime ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // دالة لتعيين الوقت الحالي
  void _setNow() {
    setState(() {
      _selectedDateTime = DateTime.now();
    });
    _saveTime();
  }

  // دالة لحفظ الوقت
  void _saveTime() {
    if (_selectedDateTime != null) {
      // هنا يمكنك إرسال الوقت إلى الـ Cubit أو الـ Repo لتخزينه في السيرفر
      context.read<MasterClockCubit>().editSlaveClock(time: _selectedDateTime!);
      showSnackBar(context, 'Time saved successfully');
      context.pop();
    }
  }
}
