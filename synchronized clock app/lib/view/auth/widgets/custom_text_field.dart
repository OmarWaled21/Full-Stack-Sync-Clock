import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    super.key,
    this.validator,
    required this.hintText,
    this.icon,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final IconData? icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // تثبيت اتجاه التصميم
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.greyColor),
                  top: BorderSide(color: AppColors.greyColor),
                  left: BorderSide(color: AppColors.greyColor),
                ),
              ),
              child: Icon(icon, color: AppColors.backgroundColor),
            ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextFormField(
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.greyColor),
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(50),
                      bottomRight: const Radius.circular(50),
                      topLeft: icon != null ? Radius.zero : const Radius.circular(50),
                      bottomLeft: icon != null ? Radius.zero : const Radius.circular(50),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.greyColor),
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(50),
                      bottomRight: const Radius.circular(50),
                      topLeft: icon != null ? Radius.zero : const Radius.circular(50),
                      bottomLeft: icon != null ? Radius.zero : const Radius.circular(50),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(50),
                      bottomRight: const Radius.circular(50),
                      topLeft: icon != null ? Radius.zero : const Radius.circular(50),
                      bottomLeft: icon != null ? Radius.zero : const Radius.circular(50),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
