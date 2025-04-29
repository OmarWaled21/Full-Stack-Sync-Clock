import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/media_query_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/repositories/accounts_repo.dart';
import 'package:synchronized_clock/repositories/add_deivce_repo.dart';
import 'package:synchronized_clock/repositories/home_repo.dart';
import 'package:synchronized_clock/repositories/logs_repo.dart';
import 'package:synchronized_clock/view/accounts/page/accounts_page.dart';
import 'package:synchronized_clock/view/add_device/pages/bluetooth_page.dart';
import 'package:synchronized_clock/view/auth/pages/login_page.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view/home/pages/edit_master_clock.dart';
import 'package:synchronized_clock/view/home/pages/support_page.dart';
import 'package:synchronized_clock/view/home/widgets/language_selection_dialog.dart';
import 'package:synchronized_clock/view/logs/pages/view_logs_page.dart';
import 'package:synchronized_clock/view/messages/pages/enable_messages.dart';
import 'package:synchronized_clock/view_model/accounts_cubit/accounts_cubit.dart';
import 'package:synchronized_clock/view_model/add_device_cubit/add_device_cubit.dart';
import 'package:synchronized_clock/view_model/auth_cubit/auth_cubit.dart';
import 'package:synchronized_clock/view_model/logs_cubit/logs_cubit.dart';
import 'package:synchronized_clock/view_model/bluetooth_cubit/bluetooth_cubit.dart';
import 'package:synchronized_clock/view_model/master_clock_cubit/master_clock_cubit.dart';
import 'package:synchronized_clock/view_model/messages_cubit/messages_cubit.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: context.screenWidth * 0.7,
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.backgroundColor),
            child: Container(
              width: context.screenWidth * 0.7,
              color: AppColors.backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/tomatiki_logo_dark_theme.png', width: 200),
                  Text(
                    '${context.lang.welcome} ${context.read<AuthCubit>().currentUser!.username}',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main body of the drawer
          Column(
            children: [
              if (context.read<AuthCubit>().currentUser!.rule == 'admin')
                Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(context.lang.users),
                      onTap: () {
                        context.push(
                          BlocProvider(
                            create: (context) => AccountsCubit(AccountsRepo())..fetchUsers(),
                            child: AccountsPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text(context.lang.addDevice),
                      onTap: () {
                        context.push(
                          MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => BluetoothCubit()..initializeBluetooth(),
                              ),
                              BlocProvider(create: (context) => AddDeviceCubit(AddDeivceRepo())),
                            ],
                            child: BluetoothScanScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text(context.lang.messages),
                      onTap: () {
                        context.push(
                          BlocProvider(
                            create: (context) => MessagesCubit(),
                            child: const EnableMessages(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              if (context.read<AuthCubit>().currentUser!.rule != 'user')
                Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.insert_drive_file_outlined),
                      title: Text(context.lang.logs),
                      onTap: () {
                        context.push(
                          BlocProvider(
                            create: (context) => LogsCubit(LogsRepo())..fetchLogs(),
                            child: const ViewLogsPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.timer_sharp),
                      title: Text(context.lang.edit_time),
                      onTap: () {
                        context.push(
                          BlocProvider(
                            create: (context) => MasterClockCubit(HomeRepo())..startClock(),
                            child: EditMasterClock(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ListTile(
                leading: Icon(Icons.support_agent),
                title: Text(context.lang.supports),
                onTap: () {
                  context.push(SupportPage());
                },
              ),
              ListTile(
                leading: Icon(Icons.translate),
                title: Text(context.lang.language), // أو أي ترجمة مناسبة
                onTap: () {
                  showDialog(context: context, builder: (context) => LanguageSelectionDialog());
                },
              ),
            ],
          ),
          // Spacer to push the logout button to the bottom of the drawer
          Spacer(),
          // Logout button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              color: AppColors.primaryColor,
              borderColor: AppColors.whiteColor,
              text: context.lang.logout,
              onPressed: () {
                context.read<AuthCubit>().logout();
                context.push(LoginPage());
              },
            ),
          ),
        ],
      ),
    );
  }
}
