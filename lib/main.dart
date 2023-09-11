import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:NearbyNexus/screens/admin/dashboard.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/user/screens/user_home.dart';
import 'package:NearbyNexus/screens/user/screens/user_otp_screen.dart';
import 'package:NearbyNexus/screens/user/screens/user_profile.dart';
import 'package:NearbyNexus/screens/user/screens/user_profile_one.dart';
import 'package:NearbyNexus/screens/vendor/screens/update_vendor_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_home.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_profile.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_profile_one.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'config/themes/app_theme.dart';
import 'screens/admin/screens/add_data.dart';
import 'screens/user/screens/complete_registration_user.dart';
import 'screens/vendor/screens/vendor_portfolio.dart';
import 'screens/vendor/screens/registration_vendor_one.dart';
import 'screens/common_screens/forgot_password.dart';
import 'screens/common_screens/initial_page.dart';
import 'screens/common_screens/login_screen.dart';
import 'screens/common_screens/registration_screen.dart';
import 'screens/common_screens/splash_screen.dart';
import 'screens/common_screens/user_or_vendor.dart';
import 'screens/vendor/screens/registration_vendor_two.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final userProvider = UserProvider(); // Create an instance of UserProvider
  userProvider.setUid(); // Retrieve and set the uid
  runApp(
    ChangeNotifierProvider.value(
      value: userProvider, // Provide the UserProvider to your app
      child: const MyApp(),
    ),
  );
  // DependencyInjection.init();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
        "final_form_vendor": (context) => const FinalSubmitFormVendor(),
        "login_screen": (context) => const LoginScreen(),
        "admin_screen": (context) => const Dashboard(),
        "forgot_password_screen": (context) => const ForgotPasswordScreen(),
        "user_home": (context) => const GeneralUserHome(),
        "vendor_home": (context) => const VendorHome(),
        "list_users": (context) => const ListUsers(),
        "data_entry": (context) => const DataEntry(),
        "vendor_profile_opposite": (context) => const VendorPortfolio(),
        "vendor_profile": (context) => const VendorProfile(),
        "user_profile_one": (context) => const UserProfileOne(),
        "vendor_profile_one": (context) => const VendorProfileOne(),
        "user_profile": (context) => const UserProfile(),
        "user_otp_screen": (context) => const UserOtpScreen(),
        "update_vendor_screen": (context) => const UpdateVendorScreen(),
      },
      initialRoute: "splashScreen",
    );
  }
}
