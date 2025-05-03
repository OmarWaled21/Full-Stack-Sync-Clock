// bluetooth/view/bluetooth_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/core/helper/show_snack_bar.dart';
import 'package:synchronized_clock/view/add_device/pages/add_device_page.dart';
import 'package:synchronized_clock/view_model/add_device_cubit/add_device_cubit.dart';
import 'package:synchronized_clock/view_model/auth_cubit/auth_cubit.dart';
import 'package:synchronized_clock/view_model/bluetooth_cubit/bluetooth_cubit.dart';
import 'package:synchronized_clock/view/add_device/widgets/wifi_credential_dialog.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  final bool isDiscovering = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddDeviceCubit, AddDeviceState>(
      listener: (context, state) {
        if (state is AddDeviceLoaded) {
          Navigator.of(context, rootNavigator: true).pop(); // يقفل الـ loading dialog
          // ثم تروح بقى على صفحة إعداد الغرفة
          context.push(AddDevicePage(slaveClockModel: state.device, deviceId: state.deviceId));
        } else if (state is AddDeviceError) {
          Navigator.of(context, rootNavigator: true).pop(); // يقفل الـ loading
          showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
          ),
          title: Text(
            context.lang.addNewDevice,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteColor),
          ),
          centerTitle: true,
          backgroundColor: AppColors.backgroundColor,
        ),
        body: BlocBuilder<BluetoothCubit, BluetoothConfState>(
          builder: (context, state) {
            if (state is BluetoothLoading) {
              return Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballScaleRippleMultiple,
                  colors: isDiscovering ? null : [AppColors.blueColor],
                ),
              );
            } else if (state is BluetoothDevicesLoaded) {
              return Column(
                children: [
                  _buildBluetoothButton(context, isDiscovering),
                  Expanded(
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        side: BorderSide(color: AppColors.blueColor),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          itemCount: state.devices.length,
                          itemBuilder: (context, index) {
                            final device = state.devices[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(device.name ?? device.address),
                                  onTap: () {
                                    context.read<BluetoothCubit>().connectToDevice(device);
                                  },
                                ),
                                const Divider(color: AppColors.blueColor),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is BluetoothConnected) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showCredentialsDialog(context, state.device);
              });
            } else if (state is BluetoothWiFiCredentialsSent) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                context.read<AddDeviceCubit>().fetchDeviceByIdWithRetry(
                  state.deviceId, // أو أي `deviceId` فعلي بترسله من ESP
                );
              });
              // Navigate to the room configuration page
            } else if (state is BluetoothError) {
              return Column(
                children: [
                  _buildBluetoothButton(context, isDiscovering),
                  Center(child: Text(state.message)),
                ],
              );
            }

            return Column(
              children: [
                _buildBluetoothButton(context, isDiscovering),
                Center(child: Text(context.lang.noDevicesFound)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBluetoothButton(BuildContext context, bool isDiscovering) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LoadingIndicator(
          indicatorType: Indicator.ballScaleRippleMultiple,
          colors: isDiscovering ? null : [Colors.transparent],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDiscovering ? AppColors.primaryColor : AppColors.greyColor,
          ),
          child: IconButton(
            onPressed: () => isDiscovering ? null : context.read<BluetoothCubit>().scanDevices(),
            icon: const Icon(Icons.bluetooth, size: 40),
            padding: const EdgeInsets.all(22),
          ),
        ),
      ],
    );
  }

  void _showCredentialsDialog(BuildContext parentContext, BluetoothDevice device) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        final ssidController = TextEditingController();
        final passwordController = TextEditingController();
        return WifiCredentialsDialog(
          ssidController: ssidController,
          passwordController: passwordController,
          onCancel: () => dialogContext.pop(),
          onSendCredentials: () {
            // استخدم الـ context من الشاشة الأساسية
            parentContext.read<BluetoothCubit>().sendWiFiCredentials(
              device,
              ssidController.text,
              passwordController.text,
              parentContext.read<AuthCubit>().currentUser!.token!,
            );
            dialogContext.pop();
          },
        );
      },
    );
  }
}
