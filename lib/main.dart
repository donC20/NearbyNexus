// ignore_for_file: avoid_print, unused_element

import 'package:NearbyNexus/components/global_bottom_navigation.dart';
import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/providers/common_provider.dart';
import 'package:NearbyNexus/screens/admin/dashboard.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/common_screens/success_screen.dart';
import 'package:NearbyNexus/screens/common_screens/terms_nd_conditions.dart';
import 'package:NearbyNexus/screens/user/components/view_job_details.dart';
import 'package:NearbyNexus/screens/user/screens/active_jobs.dart';
import 'package:NearbyNexus/screens/user/screens/chatScreen/user_inbox.dart';
import 'package:NearbyNexus/screens/user/screens/create_job_post.dart';
import 'package:NearbyNexus/screens/user/screens/favorites.dart';
import 'package:NearbyNexus/screens/user/screens/job_history.dart';
import 'package:NearbyNexus/screens/user/screens/job_review_page.dart';
import 'package:NearbyNexus/screens/user/screens/my_job_posts.dart';
import 'package:NearbyNexus/screens/user/screens/new_request.dart';
import 'package:NearbyNexus/screens/user/screens/rate_user_screen.dart';
import 'package:NearbyNexus/screens/user/screens/request_pending_user.dart';
import 'package:NearbyNexus/screens/user/screens/request_status_page.dart';
import 'package:NearbyNexus/screens/user/screens/user_dashboard_m.dart';
import 'package:NearbyNexus/screens/user/screens/user_home.dart';
import 'package:NearbyNexus/screens/user/screens/user_otp_screen.dart';
import 'package:NearbyNexus/screens/user/screens/user_payments_log.dart';
import 'package:NearbyNexus/screens/user/screens/user_profile.dart';
import 'package:NearbyNexus/screens/user/screens/user_profile_one.dart';
import 'package:NearbyNexus/screens/vendor/components/search_services_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/BidForJob.dart';
import 'package:NearbyNexus/screens/vendor/screens/broadcasts.dart';
import 'package:NearbyNexus/screens/vendor/screens/job_description_preview.dart';
import 'package:NearbyNexus/screens/vendor/screens/job_details.dart';
import 'package:NearbyNexus/screens/vendor/screens/job_log_timeline.dart';
import 'package:NearbyNexus/screens/vendor/screens/jobs_log.dart';
import 'package:NearbyNexus/screens/vendor/screens/my_applications.dart';
import 'package:NearbyNexus/screens/vendor/screens/new_jobs.dart';
import 'package:NearbyNexus/screens/vendor/screens/payments_log.dart';
import 'package:NearbyNexus/screens/vendor/screens/proposal_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/proposal_view_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/saved_posts.dart';
import 'package:NearbyNexus/screens/vendor/screens/update_vendor_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_dashboard.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_home.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_kyc.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_notification_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_profile.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_profile_one.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_side_search_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/view_requests.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'config/themes/app_theme.dart';
import 'screens/admin/screens/add_data.dart';
import 'screens/vendor/screens/vendor_portfolio.dart';
import 'screens/vendor/screens/registration_vendor_one.dart';
import 'screens/common_screens/forgot_password.dart';
import 'screens/common_screens/initial_page.dart';
import 'screens/common_screens/login_screen.dart';
import 'screens/common_screens/registration_screen.dart';
import 'screens/common_screens/splash_screen.dart';
import 'screens/common_screens/user_or_vendor.dart';
import 'screens/vendor/screens/registration_vendor_two.dart';

var log = Logger();
//global object for accessing device screen size

// notification local init
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);
void main() async {
  // GlobalNotifications allNotify = GlobalNotifications();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  print('\nNotification Channel Result: $result');
  // FirebaseMessaging.onBackgroundMessage(
  //     allNotify.firebaseMessagingBackgroundHandler);
  // allNotify.requestMonitor();
  // final firebaseNotifications = FirebaseNotifications(); // Create an instance
  // await firebaseNotifications.initNotifications();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  Stripe.publishableKey =
      "pk_test_51NpN8rSJaMBnAdU7brX75geJWwHJ7OQnD9Aq9fZFaZFehX8ERy1w1yskGN1O0EOACM2am8XUjsAOkIr26U35YDSe00DbSFVmLl";
  final userProvider = UserProvider(); // Create an instance of UserProvider
  userProvider.setUid(); // Retrieve and set the uid

  runApp(
    ChangeNotifierProvider(
      create: (context) => CommonProvider(),
      child: const MyApp(),
    ),
  );
  // DependencyInjection.init();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (ApiFunctions.auth.currentUser != null) {
      ApiFunctions.getFirebaseMessagingToken();
      ApiFunctions.updateActiveStatus(true);
    } else {
      print('no users found');
    }

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (ApiFunctions.auth.currentUser != null) {
      if (state == AppLifecycleState.resumed) {
        ApiFunctions.updateActiveStatus(true);
      } else if (state == AppLifecycleState.paused) {
        ApiFunctions.updateActiveStatus(false);
      } else if (state == AppLifecycleState.inactive) {
        ApiFunctions.updateActiveStatus(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'NearbyNexus',
      theme: AppTheme.basic,
      routes: {
        "admin_screen": (context) => const Dashboard(),
        "splashScreen": (context) => const SplashScreen(),
        "initial_page": (context) => const InitialPage(),
        // "/global_bottom_navigation": (context) => const GlobalBottomNavigation(),
        "login_screen": (context) => const LoginScreen(),
        "forgot_password_screen": (context) => const ForgotPasswordScreen(),
        "user_or_vendor": (context) => const UserOrVendor(),
        "registration_screen": (context) => const RegistrationScreen(),
        "terms_Conditions": (context) => const TermsAndConditionsScreen(),
        "/success_screen": (context) => const SuccessScreen(),

        // vendor _screens
        "complete_registration_vendor": (context) =>
            const CompleteRegistrationByvendor(),
        "final_form_vendor": (context) => const FinalSubmitFormVendor(),
        "vendor_home": (context) => const VendorHome(),
        "vendor_profile_opposite": (context) => const VendorPortfolio(),
        "vendor_profile": (context) => const VendorProfile(),
        "vendor_profile_one": (context) => const VendorProfileOne(),
        "update_vendor_screen": (context) => const UpdateVendorScreen(),
        "vendor_notification": (context) => const VendorNotificationScreen(),
        "vendor_dashboard": (context) => const VendorDashboard(),
        "search_screen_vendor": (context) => const VendorSideSearchScreen(),
        "payment_vendor_log": (context) => const PaymentVendorLogScreen(),
        "add_services_screen": (context) => const SearchScreenServices(),
        "/vendor_kyc_screen": (context) => KYCScreen(),
        "vendor_accepted_job": (context) => MyJobs(),
        //  user_pages
        "user_home": (context) => const GeneralUserHome(),
        "user_dashboard": (context) => const UserDashboardM(),
        "new_request": (context) => NewServiceRequest(),
        "list_users": (context) => const ListUsers(),
        "data_entry": (context) => const DataEntry(),
        "user_profile_one": (context) => const UserProfileOne(),
        "user_profile": (context) => const UserProfile(),
        "user_otp_screen": (context) => const UserOtpScreen(),
        "request_status_page": (context) => const RequestStatusPage(),
        "job_review_page": (context) => const JobReviewPage(),
        "view_job_details": (context) => const ViewJobDetails(),
        "view_requests": (context) => const ViewRequests(),
        "new_jobs": (context) => const NewJobs(),
        "job_logs": (context) => const JobLogs(),
        "job_log_timeline": (context) => const JobLogTimeline(),
        "rate_user_screen": (context) => const RateUserScreen(),
        "user_payment_log": (context) => const PaymentUserLogScreen(),
        "user_active_jobs": (context) => const UserActiveJobs(),
        "user_pending_requets": (context) => const RequestsPendingUser(),
        "/user_job_history": (context) => const UserJobHistory(),
        "/my_favourites": (context) => const MyFavourites(),
        //---------------------------- main--------------------------------

        // user
        "/create_job_post": (context) => const CreateJobPost(),
        "/view_my_job_post": (context) => MyJobPosts(),
        "/user_inbox": (context) => const UserInbox(),
        // vendor
        "/broadcast_page": (context) => const BroadcastPage(),
        "/job_detail_page": (context) => const JobDetailPage(),
        "/bid_for_job": (context) => const BidForJob(),
        "/proposal_screen": (context) => ProposalScreen(),
        "/proposal_view_screen": (context) => const ProposalViewScreen(),
        "/view_saved_jobs_screen": (context) => SavedJobsScreen(),
        "/view_my_applications_screen": (context) => MyApplications(),
      },
      initialRoute: "splashScreen",
    );
  }
}

