import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_text_field.dart';
import 'package:synchronized_clock/view/home/pages/home_page.dart';
import 'package:synchronized_clock/view_model/home_cubit/home_cubit.dart';

class AddDevicePage extends StatefulWidget {
  final SlaveClockModel? slaveClockModel;
  final String deviceId;
  const AddDevicePage({super.key, this.slaveClockModel, required this.deviceId});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _nameController = TextEditingController();
  final _maxTempController = TextEditingController(text: '40');
  final _minTempController = TextEditingController(text: '20');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(
          children: [
            // Clock Name Field
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(context.lang.clockName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: CustomTextField(
                  controller: _nameController,
                  hintText: '${context.lang.enter} ${context.lang.clockName}',
                ),
              ),
            ),

            // Max Temperature Field
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  '${context.lang.max} ${context.lang.temperature}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: CustomTextField(
                  controller: _maxTempController,
                  hintText: '${context.lang.enter} ${context.lang.max} ${context.lang.temperature}',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),

            // Min Temperature Field
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  '${context.lang.min} ${context.lang.temperature}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: CustomTextField(
                  controller: _minTempController,
                  hintText: '${context.lang.enter} ${context.lang.min} ${context.lang.temperature}',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomButton(
                onPressed: () {
                  context.read<HomeCubit>().editSlaveClock(
                    deviceId: widget.deviceId,
                    name: _nameController.text,
                    maxTempThreshold: double.parse(_maxTempController.text),
                    minTempThreshold: double.parse(_minTempController.text),
                  );
                  context.pushAndRemoveUntil(HomePage());
                },
                borderColor: AppColors.successColor,
                text: context.lang.save,
                color: AppColors.transparentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
