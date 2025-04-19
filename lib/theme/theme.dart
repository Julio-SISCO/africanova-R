import 'dart:math';

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'Oswald',
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.grey.shade300,
    secondary: const Color(0xFF056148),
    tertiary: Colors.black,
  ),
);

ThemeData darkMode = ThemeData(
  fontFamily: 'Oswald',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF111118),
    surface: Color(0xFF262D4D),
    secondary: const Color(0xFF056148),
    tertiary: Colors.white,
  ),
);


Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
