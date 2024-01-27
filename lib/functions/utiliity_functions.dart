import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilityFunctions {
  // snackbar new
  SnackBar snackBarOpener(String title, String content, ContentType contentType,
      Color bgColor, SnackBarBehavior snackBehaviour) {
    return SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: snackBehaviour,
      backgroundColor: bgColor,
      content: AwesomeSnackbarContent(
        title: title,
        message: content,
        contentType: contentType,
        inMaterialBanner: true,
      ),
    );
  }

// Snackbar old
  void showSnackbar(
      String message, Color backgroundColor, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

// Date time calculator
  String findTimeDifference(dynamic timestamp, {String trailingText = "ago"}) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        int years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} $trailingText';
      } else if (difference.inDays > 30) {
        int months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} $trailingText';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} $trailingText';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} $trailingText';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} $trailingText';
      } else {
        return 'just now';
      }
    } else {
      return 'Invalid timestamp';
    }
  }

// Format amount count to letters
  String shortScaleNumbers(double count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      double result = count / 1000.0;
      return '${result.toStringAsFixed(1)}k';
    } else {
      double result = count / 1000000.0;
      return '${result.toStringAsFixed(1)}M';
    }
  }

  // Salary formater
  String formatSalary(double salary) {
    if (salary < 1000) {
      return salary.toString();
    } else {
      String formattedSalary = salary.toString();
      String result = '';
      int count = 0;

      for (int i = formattedSalary.length - 1; i >= 0; i--) {
        result = formattedSalary[i] + result;
        count++;

        if (count == 3 && i > 0) {
          result = ',$result';
          count = 0;
        }
      }

      return result;
    }
  }

// Text truncator
  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return "${text.substring(0, maxLength)}...";
    }
  }

// add to shared preference

  Future<bool> sharedPreferenceCreator(String key, dynamic value) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString(key, value.toString());
      return true; // Operation was successful
    } catch (e) {
      print("Error setting SharedPreferences: $e");
      return false; // Operation failed
    }
  }

// fetch from shared preference

  Future<dynamic> fetchFromSharedPreference(String key) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    dynamic storeData = sharedPreferences.getString(key);

    if (storeData != null && storeData.isNotEmpty) {
      return storeData;
    } else {
      return null;
    }
  }


// remove from shared preference
// Function to delete data from SharedPreferences based on the provided key
Future<void> deleteFromSharedPreferences(String key) async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove(key);
}

// end of the class
}
