import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'Inter',
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.grey.shade300,
    secondary: Color(0xFF7E0589),
    tertiary: Colors.black,
  ),
);

ThemeData darkMode = ThemeData(
  fontFamily: 'Inter',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF111118),
    primary: Color(0xFF262D4D),
    secondary: Color(0xFF7E0589),
    tertiary: Colors.white,
  ),
);
