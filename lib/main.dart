import 'package:flutter/material.dart';
import 'pages/otpLogin.dart';
import 'package:provider/provider.dart';
import 'appwrite/auth.dart';
import 'pages/home.dart';
import 'widgets/Astartup_loading.dart';
import 'pages/onboarding.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: ((context) => AuthAPI()), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final value = context.watch<AuthAPI>().status;
    print('TOP CHANGE Value changed to: $value!');

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: value == AuthStatus.uninitialized
          ? const Scaffold(
              body: const StartupLoader(),
            )
          : value == AuthStatus.authenticated
              ? const Onboarding()
              : MaterialApp(
                  home: OTPVerificationPage(),
                ),
    );
  }
}
