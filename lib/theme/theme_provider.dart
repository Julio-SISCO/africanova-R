import 'package:africanova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveTheme(themeData == lightMode);
    notifyListeners();
  }

  void toggleTheme() {
    themeData = (_themeData == lightMode) ? darkMode : lightMode;
  }

  bool isLightTheme() {
    return _themeData == lightMode;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLight = prefs.getBool('isLightTheme') ?? true;
    _themeData = isLight ? lightMode : darkMode;
    notifyListeners();
  }

  Future<void> _saveTheme(bool isLight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightTheme', isLight);
  }
}
