import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Color _primaryColor = Colors.lightBlueAccent;

  Color get primaryColor => _primaryColor;

  void setTheme(Color themeColor) {
    _primaryColor = themeColor;
    notifyListeners();
  }
}
