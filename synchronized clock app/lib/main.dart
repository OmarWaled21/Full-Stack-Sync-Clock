import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:synchronized_clock/core/helper/simple_bloc_opserver.dart';
import 'package:synchronized_clock/core/background_services/background_service_handler.dart';
import 'package:synchronized_clock/core/messaging/notification_service.dart';
import 'package:synchronized_clock/generated/l10n.dart';
import 'package:synchronized_clock/repositories/auth_repo.dart';
import 'package:synchronized_clock/repositories/home_repo.dart';
import 'package:synchronized_clock/view/splash/page/splash_page.dart';
import 'package:synchronized_clock/view_model/auth_cubit/auth_cubit.dart';
import 'package:synchronized_clock/view_model/localization_cubit/localization_cubit.dart';
import 'package:synchronized_clock/view_model/home_cubit/home_cubit.dart';

void main() async {
  Bloc.observer = SimpleBlocOpserver();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await BackgroundServiceHandler.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepo())),
        BlocProvider(create: (_) => HomeCubit(HomeRepo())..startAutoFetch()),
        BlocProvider(create: (_) => LocalizationCubit()), // إضافة Cubit الخاص بالترجمة
      ],
      child: BlocBuilder<LocalizationCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
