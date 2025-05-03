import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';

class SeeAllCard extends StatelessWidget {
  final VoidCallback onTap;
  const SeeAllCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final isWide = width > 600;
    final titleSize = isWide ? 20.0 : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.blueColor),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Center(
          child: Text(
            'See All',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
              color: AppColors.blueColor,
            ),
          ),
        ),
      ),
    );
  }
}
