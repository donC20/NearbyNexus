// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light theme
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Colors.white,
    primary: Color(0xff3E61ED),
    // primary grey chat
    onPrimary: Color.fromARGB(160, 158, 158, 158),
    // title
    onSecondary: Color(0xff343740),
    // containers
    onSecondaryContainer: Color.fromARGB(255, 255, 255, 255),
    // subtitles
    tertiary: Color.fromARGB(255, 114, 114, 114),
    // icons
    onTertiary: Color.fromARGB(255, 107, 107, 107),
    // border
    outline: Color.fromARGB(98, 127, 127, 127),
    // boxshadow
    shadow: Color(0x007c7b7b),
    // Divider
    surface: Color.fromARGB(115, 86, 86, 86),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(243, 255, 255, 255),
    elevation: 1,
    titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        fontFamily: GoogleFonts.play().fontFamily),
  ),
);

// Dark theme
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 1,
    titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        fontFamily: GoogleFonts.play().fontFamily),
  ),
  colorScheme: const ColorScheme.dark(
    background: Color(
      0xFF0F1014,
    ),
    primary: Color(0xff3E61ED),
    onPrimary: Colors.white,
    onSecondary: Color.fromARGB(255, 255, 255, 255),
    onSecondaryContainer: Color.fromARGB(43, 158, 158, 158),
    tertiary: Colors.white,
    onTertiary: Color.fromARGB(255, 255, 255, 255),
    outline: Color.fromARGB(28, 255, 255, 255),
    surface: Color.fromARGB(89, 255, 255, 255),
  ),
);
