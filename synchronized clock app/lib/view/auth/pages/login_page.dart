import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:synchronized_clock/core/helper/show_snack_bar.dart';
import 'package:synchronized_clock/core/strings.dart';
import 'package:synchronized_clock/repositories/auth_repo.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_button.dart';
import 'package:synchronized_clock/view/auth/widgets/custom_text_field.dart';
import 'package:synchronized_clock/view/auth/widgets/password_text_field.dart';
import 'package:synchronized_clock/view/home/pages/home_page.dart';
import 'package:synchronized_clock/view_model/auth_cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

late TextEditingController usernameController;
late TextEditingController passwordController;
late TextEditingController emailController;

AuthRepo apiService = AuthRepo();

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        centerTitle: true,
        title: Image.asset(AppStrings.logoDarkTheme, height: 40),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% of the screen width for padding
              vertical: screenHeight * 0.1, // 10% of the screen height for vertical padding
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.lang.login,
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 40 : 30, // Larger text on wider screens
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // 5% vertical space
                  CustomTextField(
                    controller: usernameController,
                    hintText: context.lang.username,
                    icon: IconData(0x40),
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% vertical space
                  PasswordTextField(
                    controller: passwordController,
                    hintText: context.lang.password,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(context.lang.resetPassword),
                              content: CustomTextField(
                                hintText: context.lang.email,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text(context.lang.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<AuthCubit>().forgotPassword(
                                      emailController.text.trim(),
                                    );
                                    context.pop();
                                  },
                                  child: Text(context.lang.send),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
                      child: Text(context.lang.forgotPassword),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% vertical space
                  BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        context.pushAndRemoveUntil(const HomePage());
                        showSnackBar(context, context.lang.loginSuccessful);
                      } else if (state is AuthFailure) {
                        showSnackBar(context, state.message);
                      }
                    },
                    child: CustomButton(
                      onPressed: () {
                        context.read<AuthCubit>().login(
                          usernameController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      text: context.lang.login,
                      color: AppColors.transparentColor,
                      borderColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
