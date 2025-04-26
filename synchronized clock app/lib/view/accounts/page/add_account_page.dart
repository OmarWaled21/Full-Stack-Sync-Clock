import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/core/helper/show_snack_bar.dart';
import 'package:synchronized_clock/core/strings.dart';
import 'package:synchronized_clock/repositories/accounts_repo.dart';
import 'package:synchronized_clock/repositories/auth_repo.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_text_field.dart';
import 'package:synchronized_clock/view/auth/widgets/password_text_field.dart';
import 'package:synchronized_clock/view/home/pages/home_page.dart';
import 'package:synchronized_clock/view_model/accounts_cubit/accounts_cubit.dart';
import 'package:synchronized_clock/view_model/auth_cubit/auth_cubit.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

late TextEditingController firstNameController;
late TextEditingController lastNameController;
late TextEditingController usernameController;
late TextEditingController passwordController;
late TextEditingController emailController;
String _selectedRole = 'user';

AuthRepo apiService = AuthRepo();

class _AddAccountPageState extends State<AddAccountPage> {
  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
        ),
        centerTitle: true,
        title: Image.asset(AppStrings.logoDarkTheme, height: 40),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35).copyWith(bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.lang.addAccount,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: CustomTextField(
                      controller: firstNameController,
                      hintText: context.lang.firstName,
                      icon: Icons.person,
                    ),
                  ),
                  SizedBox(width: 6),
                  SizedBox(
                    width: 160,
                    child: CustomTextField(
                      controller: lastNameController,
                      hintText: context.lang.lastName,
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: usernameController,
                hintText: context.lang.username,
                icon: IconData(0x40),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                hintText: context.lang.email,
                icon: IconData(0x40),
              ),
              SizedBox(height: 16),
              PasswordTextField(controller: passwordController, hintText: context.lang.password),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: context.lang.selectRole,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  DropdownMenuItem(value: 'user', child: Text(context.lang.user)),
                  DropdownMenuItem(value: 'supervisor', child: Text(context.lang.supervisor)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    context.pushAndRemoveUntil(const HomePage());
                    showSnackBar(context, context.lang.registrationSuccess);
                  } else if (state is AuthFailure) {
                    showSnackBar(context, state.message);
                  }
                },
                child: BlocProvider(
                  create: (context) => AccountsCubit(AccountsRepo()),
                  child: CustomButton(
                    onPressed: () {
                      context.read<AccountsCubit>().addUser(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        username: usernameController.text,
                        email: emailController.text,
                        rule: 'user',
                        password: passwordController.text,
                      );
                      context.pop();
                    },
                    text: context.lang.addAccount,
                    color: AppColors.transparentColor,
                    borderColor: AppColors.blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
