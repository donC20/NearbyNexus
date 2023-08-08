import 'package:NearbyNexus/screens/admin/screens/dashboard.dart';
import 'package:NearbyNexus/screens/complete_registration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:NearbyNexus/screens/initial_page.dart';
import 'package:NearbyNexus/screens/login_screen.dart';
import 'package:NearbyNexus/screens/registration_screen.dart';
import 'package:NearbyNexus/screens/splash_screen.dart';
import 'package:NearbyNexus/screens/user_or_vendor.dart';

import 'config/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      theme: AppTheme.basic,
      routes: {
        "splashScreen": (context) => const SplashScreen(),
        "initial_page": (context) => const InitialPage(),
        "user_or_vendor": (context) => const UserOrVendor(),
        "registration_screen": (context) => const RegistrationScreen(),
        "complete_registration": (context) => const CompleteRegistration(),
        "login_screen": (context) => const LoginScreen(),
        "admin_screen": (context) => const AdminDashboard(),
      },
      initialRoute: "splashScreen",
    );
  }
}
