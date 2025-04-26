import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/view/home/widgets/custom_drawer.dart';
import 'package:synchronized_clock/view/home/widgets/device_overview.dart';
import 'package:synchronized_clock/view/home/widgets/slave_clocks_list.dart';
import 'package:synchronized_clock/view/home/widgets/time_now.dart';
import 'package:synchronized_clock/view_model/home_cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  // Add a GlobalKey for ScaffoldState

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey, // Set the key here
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.lang.synchronized_clock,
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              // Open the endDrawer using the ScaffoldState key
              scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Icon(Icons.menu, color: AppColors.whiteColor),
          ),
        ],
      ),
      endDrawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                context.lang.master_clock,
                style: TextStyle(fontSize: 30, color: AppColors.backgroundColor),
              ),
              TimeNow(),
              // Device overview
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeSuccess) {
                    // Get device stats from the cubit
                    final stats = context.read<HomeCubit>().getDeviceStats();
                    final slaveClocks = state.slavesClocks;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DeviceOverview(stats: stats),
                        SizedBox(height: 20),
                        Text(
                          context.lang.slave_clocks,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SlaveClocksGridView(slaveClocks: slaveClocks),
                      ],
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
