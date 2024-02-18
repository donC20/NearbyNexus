import 'package:flutter/material.dart';

class CommonProvider extends ChangeNotifier {
  bool _isDescriptionAdded = false;
  bool _isMessageSent = false;

// getters
  bool get isDescriptionAdded => _isDescriptionAdded;
  bool get isMessageSent => _isMessageSent;

// functions
// Description button in create_job_post.dart
  void changeDescriptionBtnState(bool btnState) {
    _isDescriptionAdded = btnState;
    notifyListeners();
  }

  void messageSentDetector(bool messageState) {
    _isMessageSent = messageState;
    notifyListeners();
  }
}
