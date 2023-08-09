import 'package:flutter/material.dart';

/// all custom application theme
class AppTheme {
  /// default application theme
  static ThemeData get basic => ThemeData(
        // fontFamily: Font.poppins,
        primaryColorDark: const Color.fromRGBO(111, 88, 255, 1),
        primaryColor: const Color.fromRGBO(128, 109, 255, 1),
        primaryColorLight: const Color.fromRGBO(159, 84, 252, 1),
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(128, 109, 255, 1),
        ).merge(
          ButtonStyle(elevation: MaterialStateProperty.all(0)),
        )),
        canvasColor: Color.fromARGB(255, 255, 255, 255),
        cardColor: Color.fromARGB(255, 253, 253, 253),
        // canvasColor: const Color.fromRGBO(31, 29, 44, 1),
        // cardColor: const Color.fromRGBO(38, 40, 55, 1),
      );

  // you can add other custom theme in this class like  light theme, dark theme ,etc.

  // example :
  // static ThemeData get light => ThemeData();

  // static ThemeData get dark => ThemeData();
}
