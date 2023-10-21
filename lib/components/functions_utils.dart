// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class FunctionInvoker {
// dialog
  showCancelDialog(BuildContext context, Function onTapFunction,title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "This action can't be reversed!",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                onTapFunction();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// snackbar

  showAwesomeSnackbar(
      BuildContext context, statement, bgColor, textColor, icon, iconColor) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
          SizedBox(width: 10),
          Text(
            statement,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        textColor: Colors.green,
        onPressed: () {
          // Undo action logic here
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
