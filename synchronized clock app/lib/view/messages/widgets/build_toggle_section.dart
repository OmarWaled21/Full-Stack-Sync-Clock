import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';

Widget buildToggleSection({
  required String title,
  required String description,
  required bool isEnabled,
  required Function(bool) onToggle,
  required TextEditingController controller,
  String? Function(String)? validator,
  required String label,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(value: isEnabled, onChanged: onToggle, activeColor: AppColors.primaryColor),
        ],
      ),
      const SizedBox(height: 8),
      Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      if (isEnabled)
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: TextFormField(
            controller: controller,
            cursorColor: AppColors.successColor,
            validator: validator == null ? null : (val) => validator(val ?? ''),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: AppColors.successColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.successColor, width: 2.0),
              ),
            ),
          ),
        ),
      const SizedBox(height: 20),
    ],
  );
}
