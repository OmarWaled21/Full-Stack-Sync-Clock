import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/home/widgets/clock_card.dart';

class SlaveClocksGridView extends StatelessWidget {
  final List<SlaveClockModel> slaveClocks;
  final int crossAxisCount;
  const SlaveClocksGridView({super.key, required this.slaveClocks, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    final aspectRatio = context.screenWidth / (context.screenHeight * 0.5);
    return GridView.count(
      shrinkWrap: true, // مهم لتجنب مشاكل التخطيط
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio.clamp(0.5, 1.5),
      children:
          slaveClocks.map((clock) {
            return ClockCard(clock: clock);
          }).toList(),
    );
  }
}
