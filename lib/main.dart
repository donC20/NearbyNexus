import 'package:flutter/material.dart';
import 'package:NearbyNexus/screens/initial_page.dart';
import 'package:NearbyNexus/screens/login_screen.dart';
import 'package:NearbyNexus/screens/registration_screen.dart';
import 'package:NearbyNexus/screens/splash_screen.dart';
import 'package:NearbyNexus/screens/user_or_vendor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NearbyNexus',
      routes: {
        "splashScreen": (context) => const SplashScreen(),
        "initial_page": (context) => const InitialPage(),
        "user_or_vendor": (context) => const UserOrVendor(),
        "registration_screen": (context) => const RegistrationScreen(),
        "login_screen": (context) => const LoginScreen(),
      },
      initialRoute: "splashScreen",
    );
  }
}
