import 'package:NearbyNexus/config/themes/theme.dart';
import 'package:flutter/material.dart';

class CommonProvider extends ChangeNotifier {
  bool _isDescriptionAdded = false;
  bool _isMessageSent = false;
  ThemeData _themeData = lightMode;

// getters
  bool get isDescriptionAdded => _isDescriptionAdded;
  bool get isMessageSent => _isMessageSent;
  ThemeData get themeData => _themeData;

  // setter
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

// functions
// Description button in create_job_post.dart
  void changeDescriptionBtnState(bool btnState) {
    _isDescriptionAdded = btnState;
    notifyListeners();
  }

// message send changer
  void messageSentDetector(bool messageState) {
    _isMessageSent = messageState;
    notifyListeners();
  }

  // Theme notifier
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
