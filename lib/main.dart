import 'package:NearbyNexus/screens/admin/dashboard.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/user/screens/user_home.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/themes/app_theme.dart';
import 'screens/common_screens/complete_registration_user.dart';
import 'screens/common_screens/complete_registration_vendor.dart';
import 'screens/common_screens/forgot_password.dart';
import 'screens/common_screens/initial_page.dart';
import 'screens/common_screens/login_screen.dart';
import 'screens/common_screens/registration_screen.dart';
import 'screens/common_screens/splash_screen.dart';
import 'screens/common_screens/user_or_vendor.dart';

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
        "complete_registration_user": (context) =>
            const CompleteRegistrationByUser(),
        "complete_registration_vendor": (context) =>
            const CompleteRegistrationByvendor(),
        "login_screen": (context) => const LoginScreen(),
        "admin_screen": (context) => const Dashboard(),
        "forgot_password_screen": (context) => const ForgotPasswordScreen(),
        "user_home": (context) => const GeneralUserHome(),
        "vendor_home": (context) => const VendorHome(),
        "list_users": (context) => const ListUsers(),
      },
      initialRoute: "splashScreen",
    );
  }
}
