import 'dart:math';
import 'package:flutter/material.dart';

const primaryColor = Color.fromARGB(255, 74, 129, 247);
const secondaryColor = Color.fromARGB(255, 73, 250, 79);
const bgColor = Color.fromARGB(255, 255, 255, 255);

const couleurFond = Color(0xFF008000);
const couleurFond2 = Color(0xFFFFF001);

Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
