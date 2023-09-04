import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider with ChangeNotifier {
  final BuildContext context; // Add a context parameter to the constructor.

  SessionProvider(this.context); // Constructor to initialize context.

  Map<String, dynamic>? _initialSession;

  Map<String, dynamic>? get initialSession => _initialSession;

  Future<void> getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var sessionData = sharedPreferences.getString("userSessionData");

    if (sessionData != null) {
      try {
        _initialSession = json.decode(sessionData);

        if (_initialSession == null) {
          _navigateToLoginScreen();
        } else {
          String userType = _initialSession!["userType"];
          final SharedPreferences setUserUid =
              await SharedPreferences.getInstance();
          setUserUid.setString("uid", _initialSession!["uid"]);
          navigateToUserScreen(userType);
        }
      } catch (e) {
        print("Error initializing app: $e");
        // Handle error if necessary
      }
    } else {
      print("No user session data found.");
      _navigateToLoginScreen();
    }
  }

  void _navigateToLoginScreen() async {
    // Delay for 2 seconds (as in your example)
    await Future.delayed(const Duration(seconds: 2));
    // Replace with your navigation logic (e.g., Navigator.pushReplacement)
    // Example using Navigator:
    Navigator.pushReplacementNamed(context, "initial_page");
  }

  void navigateToUserScreen(String userType) {
    if (userType == "admin") {
      // Replace with your navigation logic for admin screen
      Navigator.pushReplacementNamed(context, "admin_screen");
    } else if (userType == "vendor") {
      // Replace with your navigation logic for vendor screen
      Navigator.pushReplacementNamed(context, "vendor_home");
    } else if (userType == "general_user") {
      // Replace with your navigation logic for user screen
      Navigator.pushReplacementNamed(context, "user_home");
    } else {
      print("Unknown user type");
      // Handle unknown user type if necessary
    }
  }
}
