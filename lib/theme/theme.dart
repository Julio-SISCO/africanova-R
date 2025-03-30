import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'Oswald',
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.grey.shade300,
    secondary: const Color(0xFF05CA85),
    tertiary: Colors.black,
  ),
);

ThemeData darkMode = ThemeData(
  fontFamily: 'Oswald',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF111118),
    primary: Color(0xFF262D4D),
    secondary: const Color(0xFF05CA85),
    tertiary: Colors.white,
  ),
);
