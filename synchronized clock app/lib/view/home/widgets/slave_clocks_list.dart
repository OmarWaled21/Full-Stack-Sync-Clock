import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/home/pages/all_slave_clocks_page.dart';
import 'package:synchronized_clock/view/home/widgets/clock_card.dart';
import 'package:synchronized_clock/view/home/widgets/see_all_card.dart';

class SlaveClocksGridView extends StatelessWidget {
  final List<SlaveClockModel> slaveClocks;
  final int crossAxisCount;
  const SlaveClocksGridView({super.key, required this.slaveClocks, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    final aspectRatio = context.screenWidth / (context.screenHeight * 0.5);
    final showAllCard = slaveClocks.length > 3;

    // ترتيب حسب الحالة: green ثم red ثم باقي القيم
    List<SlaveClockModel> sortedClocks = List.from(slaveClocks)..sort((a, b) {
      int getStatusRank(String status) {
        switch (status.toLowerCase()) {
          case 'red':
            return 0;
          case 'green':
            return 1;
          default:
            return 2;
        }
      }

      return getStatusRank(a.status).compareTo(getStatusRank(b.status));
    });

    return GridView.count(
      shrinkWrap: true, // مهم لتجنب مشاكل التخطيط
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio.clamp(0.5, 1.5),
      children: [
        ...(showAllCard
            ? sortedClocks.take(3).map((clock) => ClockCard(clock: clock))
            : sortedClocks.map((clock) => ClockCard(clock: clock))),

        if (showAllCard)
          SeeAllCard(onTap: () => context.push(AllSlaveClocksPage(allClocks: slaveClocks))),
      ],
    );
  }
}
