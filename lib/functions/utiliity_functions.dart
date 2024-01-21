import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
}
