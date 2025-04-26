import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized_clock/view/auth/pages/login_page.dart';
import 'package:synchronized_clock/view/home/pages/home_page.dart';
import 'package:synchronized_clock/view_model/auth_cubit/auth_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthCubit>().checkLoginStatus();

    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLogin) {
            return const LoginPage();
          } else if (state is AuthSuccess) {
            return const HomePage();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
