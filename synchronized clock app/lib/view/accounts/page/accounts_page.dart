import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/view/accounts/page/add_account_page.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view_model/accounts_cubit/accounts_cubit.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final Map<int, String> _updatedRoles = {};

  bool get hasChanges => _updatedRoles.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        title: Text(
          context.lang.users,
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<AccountsCubit, AccountsState>(
              builder: (context, state) {
                if (state is AccountsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AccountsSuccess) {
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      final currentRole = _updatedRoles[user.id] ?? user.rule;

                      return Row(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color:
                                      user.rule == 'supervisor'
                                          ? AppColors.blueColor
                                          : AppColors.backgroundColor,
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                leading: CircleAvatar(child: Text(user.username[0].toUpperCase())),
                                title: Text(user.username, style: const TextStyle(fontSize: 14)),
                                subtitle: Text(
                                  user.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: DropdownButton<String>(
                                  value: currentRole,
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.backgroundColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'user',
                                      child: Text(context.lang.users),
                                    ),
                                    DropdownMenuItem(
                                      value: 'supervisor',
                                      child: Text(context.lang.supervisor),
                                    ),
                                  ],
                                  onChanged: (newValue) {
                                    setState(() {
                                      if (newValue != null && newValue != user.rule) {
                                        _updatedRoles[user.id] = newValue;
                                      } else {
                                        _updatedRoles.remove(user.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.save,
                                  color: hasChanges ? AppColors.blueColor : AppColors.darkGreyColor,
                                ),
                                onPressed:
                                    hasChanges
                                        ? () {
                                          context.read<AccountsCubit>().editUserRole(
                                            user.id,
                                            currentRole,
                                            user.username,
                                          );
                                          setState(() {
                                            _updatedRoles.clear();
                                          });
                                        }
                                        : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.primaryColor),
                                onPressed: () {
                                  context.read<AccountsCubit>().deleteUser(user.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                } else if (state is AccountsFailure) {
                  return Center(child: Text("${context.lang.error}: ${state.message}"));
                }
                return Center(child: Text(context.lang.no_data));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                color: AppColors.blueColor,
                borderColor: AppColors.greyColor,
                text: context.lang.add_user,
                onPressed: () {
                  context.push(
                    BlocProvider.value(
                      value: context.read<AccountsCubit>(),
                      child: AddAccountPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
