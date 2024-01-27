import 'package:flutter/material.dart';

class CommonProvider extends ChangeNotifier {
  bool _isDescriptionAdded = false;

// getters
  bool get isDescriptionAdded => _isDescriptionAdded;

// functions
// Description button in create_job_post.dart
  void changeDescriptionBtnState(bool btnState) {
    _isDescriptionAdded = btnState;
    notifyListeners();
  }
}
