import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yellowAccent,
    brightness: Brightness.light
  ),
  dividerTheme: DividerThemeData(
    color: Colors.black.withValues(alpha: 0.5),
    thickness: 1,
    space: 0,
  ), 
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurpleAccent,
    brightness: Brightness.dark
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.5),
    thickness: 1,
    space: 0,
  ),
);

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;
  bool _isLightMode = true;

  ThemeData get themeData => _themeData;

  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLightMode = prefs.getBool('isLightMode') ?? true;
    _themeData = _isLightMode ? lightMode : darkMode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isLightMode = !_isLightMode;
    _themeData = _isLightMode ? lightMode : darkMode;
    await prefs.setBool('isLightMode', _isLightMode);
    notifyListeners();
  }
}