import 'package:flutter/material.dart';
import 'package:parkease/core/services/theme_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final ThemeService _themeService;

  ThemeViewModel(this._themeService) {
    _initialize();
  }

  ThemeMode get themeMode => _themeService.themeMode;
  bool get isDarkMode => _themeService.themeMode == ThemeMode.dark;

  Future<void> _initialize() async {
    // Initialize if needed
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await _themeService.toggleTheme();
    notifyListeners();
  }

  bool isDarkModeActive(BuildContext context) {
    return _themeService.isDarkMode(context);
  }
}
