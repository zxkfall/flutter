import 'dart:developer';
import 'package:maple_billing/constants/custom_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  Color _themeColor = Colors.lightBlueAccent;

  Color get themeColor => _themeColor;

  Future<void> setThemeColor(Color themeColor) async {
    final prefs = await SharedPreferences.getInstance();
    final isSuccess = await prefs.setInt(MyPreferenceKeys.currentThemeColorKey, themeColor.value);
    if (!isSuccess) {
      log('Failed to save theme color');
      return;
    }
    _themeColor = themeColor;
    notifyListeners();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeColor = prefs.getInt(MyPreferenceKeys.currentThemeColorKey) == null
        ? Colors.lightBlueAccent
        : Color(prefs.getInt(MyPreferenceKeys.currentThemeColorKey)!);
    notifyListeners();
  }
}
