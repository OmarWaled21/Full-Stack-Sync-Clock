import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_text_field.dart';

class WifiCredentialsDialog extends StatelessWidget {
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final VoidCallback onSendCredentials;
  final VoidCallback onCancel;

  const WifiCredentialsDialog({
    super.key,
    required this.ssidController,
    required this.passwordController,
    required this.onSendCredentials,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                context.lang.enterWifiCredentials,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: ssidController, hintText: 'WIFI-SSID'),
            const SizedBox(height: 16),
            CustomTextField(controller: passwordController, hintText: 'WIFI-Password'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: onSendCredentials, child: Text((context.lang.save))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                  onPressed: onCancel,
                  child: Text((context.lang.cancel), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
