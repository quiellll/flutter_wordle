import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferencesAsync _prefs;
  bool _isDarkMode = false;

  ThemeProvider(this._prefs) {
    _loadPreferences();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadPreferences() async {
    _isDarkMode = await _prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}