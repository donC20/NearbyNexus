import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UtilityFunctions {
  // snackbar
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

// Date time calculator
  String findTimeDifference(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        int years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        int months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
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

// Text truncator
  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return "${text.substring(0, maxLength)}...";
    }
  }
}
