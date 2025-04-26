import 'package:flutter/material.dart';
import 'package:synchronized_clock/model/slave_clock_model.dart';
import 'package:synchronized_clock/view/home/widgets/clock_card.dart';

class SlaveClocksGridView extends StatelessWidget {
  final List<SlaveClockModel> slaveClocks;
  const SlaveClocksGridView({super.key, required this.slaveClocks});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true, // مهم لتجنب مشاكل التخطيط
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.25,
      children:
          slaveClocks.map((clock) {
            return ClockCard(clock: clock);
          }).toList(),
    );
  }
}
