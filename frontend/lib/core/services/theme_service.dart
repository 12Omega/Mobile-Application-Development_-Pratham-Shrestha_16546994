import 'package:flutter/material.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:get_it/get_it.dart';

class ThemeService extends ChangeNotifier {
  late final StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService() {
    _storageService = GetIt.instance<StorageService>();
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  // Load theme mode from storage
  Future<void> _loadThemeMode() async {
    final themeString = _storageService.getThemeMode();

    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }

    await _storageService.setThemeMode(themeString);
    notifyListeners();
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Check if dark mode is active
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}

// Temporary ThemeViewModel for compatibility
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}