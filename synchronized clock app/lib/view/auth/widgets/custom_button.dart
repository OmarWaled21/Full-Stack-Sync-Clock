import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.color,
    required this.borderColor,
    required this.text,
    this.textStyle,
  });

  final VoidCallback? onPressed;
  final Color color;
  final Color borderColor;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 4,
        foregroundColor: borderColor,
        shadowColor: AppColors.transparentColor, // ✅ this sets the shadow color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: borderColor),
        ),
        textStyle: TextStyle(fontWeight: FontWeight.bold, color: borderColor, fontSize: 18),
        minimumSize: const Size.fromHeight(50),
      ),
      child: Text(text, style: textStyle),
    );
  }
}
