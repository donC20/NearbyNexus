// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light theme
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Colors.white,
    onSecondary: Color.fromARGB(255, 84, 84, 84),
    onSecondaryContainer: Color.fromARGB(255, 255, 255, 255),
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
  colorScheme: const ColorScheme.dark(
    background: Color(
      0xFF0F1014,
    ),
    onSecondary: Color.fromARGB(255, 255, 255, 255),
    onSecondaryContainer: Color.fromARGB(43, 158, 158, 158),
  ),
);
