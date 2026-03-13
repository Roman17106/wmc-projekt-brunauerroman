import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeOption {
  light,
  dark,
  system,
  blueCalm,
  greenFocus,
}

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'theme_option';
  static const _soundEnabledKey = 'sound_enabled';
  static const _vibrationEnabledKey = 'vibration_enabled';

  AppThemeOption _themeOption = AppThemeOption.system;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  AppThemeOption get themeOption => _themeOption;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  ThemeMode get themeMode {
    switch (_themeOption) {
      case AppThemeOption.light:
        return ThemeMode.light;
      case AppThemeOption.dark:
        return ThemeMode.dark;
      case AppThemeOption.system:
        return ThemeMode.system;
      case AppThemeOption.blueCalm:
      case AppThemeOption.greenFocus:
        return ThemeMode.light;
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final rawThemeValue = prefs.getString(_themeKey);
    final savedTheme = AppThemeOption.values.where((option) {
      return option.name == rawThemeValue;
    }).toList();

    if (savedTheme.isNotEmpty) {
      _themeOption = savedTheme.first;
    }

    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setThemeOption(AppThemeOption value) async {
    if (_themeOption == value) {
      return;
    }

    _themeOption = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value.name);
  }

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) {
      return;
    }

    _soundEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    if (_vibrationEnabled == value) {
      return;
    }

    _vibrationEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, value);
  }
}
