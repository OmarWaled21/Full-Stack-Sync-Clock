import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
import 'package:synchronized_clock/view/home/widgets/custom_drawer.dart';
import 'package:synchronized_clock/view/home/widgets/device_overview.dart';
import 'package:synchronized_clock/view/home/widgets/slave_clocks_list.dart';
import 'package:synchronized_clock/view/home/widgets/time_now.dart';
import 'package:synchronized_clock/view_model/home_cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final width = context.screenWidth;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.lang.synchronized_clock,
          style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.menu, color: AppColors.whiteColor),
          ),
        ],
      ),
      endDrawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width > 600 ? 32 : 16,
          vertical: 8,
        ).copyWith(bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                context.lang.master_clock,
                style: TextStyle(
                  fontSize: width > 600 ? 36 : 28,
                  color: AppColors.backgroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const TimeNow(),
              const SizedBox(height: 16),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeSuccess) {
                    final stats = context.read<HomeCubit>().getDeviceStats();
                    final slaveClocks = state.slavesClocks;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DeviceOverview(stats: stats),
                        const SizedBox(height: 20),
                        Text(
                          context.lang.slave_clocks,
                          style: TextStyle(
                            fontSize: width > 600 ? 22 : 18,
                            color: AppColors.backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SlaveClocksGridView(
                          slaveClocks: slaveClocks,
                          crossAxisCount:
                              width > 1000
                                  ? 4
                                  : width > 700
                                  ? 3
                                  : 2,
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
