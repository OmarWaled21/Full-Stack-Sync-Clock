import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/home/widgets/clock_card.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';

class AllSlaveClocksPage extends StatelessWidget {
  final List<SlaveClockModel> allClocks;

  const AllSlaveClocksPage({super.key, required this.allClocks});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.screenWidth > 600 ? 3 : 2;
    final aspectRatio = context.screenWidth / (context.screenHeight * 0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Slave Clocks', style: TextStyle(color: AppColors.whiteColor)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.whiteColor,
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio.clamp(0.5, 1.5),
        children: allClocks.map((clock) => ClockCard(clock: clock)).toList(),
      ),
    );
  }
}
