import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs!;
}
