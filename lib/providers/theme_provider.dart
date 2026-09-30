import 'package:flutter/material.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider managing theme mode (system, light, dark) with local persistence.
class ThemeProvider extends ChangeNotifier with SafeNotifier {
  ThemeProvider({SharedPreferences? preferences}) : _prefs = preferences {
    _loadFromPrefs();
  }

  static const String _prefKeyThemeMode = 'app_theme_mode';

  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadFromPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final savedMode = _prefs?.getString(_prefKeyThemeMode);
      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (_) {
      // In isolated pure unit tests
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_prefKeyThemeMode, mode.name);
    } catch (_) {
      // In isolated pure unit tests
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
