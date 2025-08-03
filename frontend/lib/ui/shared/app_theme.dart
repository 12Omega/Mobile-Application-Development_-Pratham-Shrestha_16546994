import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF3D5AF1);
  static const Color primaryDarkColor = Color(0xFF2A3F9D);
  static const Color accentColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color successColor = Color(0xFF43A047);

  // Light theme colors
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightTextColor = Color(0xFF1A1D1F);
  static const Color lightSecondaryTextColor = Color(0xFF6E7787);
  static const Color lightDividerColor = Color(0xFFE8ECEF);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFF8F9FA);
  static const Color darkSecondaryTextColor = Color(0xFFADB5BD);
  static const Color darkDividerColor = Color(0xFF2D2D2D);

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16.0,
    letterSpacing: 0.15,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12.0,
    letterSpacing: 0.4,
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: lightSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurfaceColor,
      foregroundColor: lightTextColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primaryColor),
    ),
    cardTheme: CardThemeData(
      color: lightSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: const DividerThemeData(
      color: lightDividerColor,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: lightTextColor),
      displayMedium: TextStyle(color: lightTextColor),
      displaySmall: TextStyle(color: lightTextColor),
      headlineLarge: TextStyle(color: lightTextColor),
      headlineMedium: TextStyle(color: lightTextColor),
      headlineSmall: TextStyle(color: lightTextColor),
      titleLarge: TextStyle(color: lightTextColor),
      titleMedium: TextStyle(color: lightTextColor),
      titleSmall: TextStyle(color: lightTextColor),
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
      bodySmall: TextStyle(color: lightSecondaryTextColor),
      labelLarge: TextStyle(color: lightTextColor),
      labelMedium: TextStyle(color: lightTextColor),
      labelSmall: TextStyle(color: lightSecondaryTextColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightSecondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: lightSecondaryTextColor,
      indicatorColor: primaryColor,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightSurfaceColor,
      disabledColor: lightDividerColor,
      selectedColor: primaryColor.withAlpha(25),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightDividerColor),
      ),
      labelStyle: const TextStyle(color: lightTextColor),
      secondaryLabelStyle: const TextStyle(color: primaryColor),
      brightness: Brightness.light,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: darkSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: darkTextColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primaryColor),
    ),
    cardTheme: CardThemeData(
      color: darkSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: const DividerThemeData(
      color: darkDividerColor,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkTextColor),
      displayMedium: TextStyle(color: darkTextColor),
      displaySmall: TextStyle(color: darkTextColor),
      headlineLarge: TextStyle(color: darkTextColor),
      headlineMedium: TextStyle(color: darkTextColor),
      headlineSmall: TextStyle(color: darkTextColor),
      titleLarge: TextStyle(color: darkTextColor),
      titleMedium: TextStyle(color: darkTextColor),
      titleSmall: TextStyle(color: darkTextColor),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkSecondaryTextColor),
      labelLarge: TextStyle(color: darkTextColor),
      labelMedium: TextStyle(color: darkTextColor),
      labelSmall: TextStyle(color: darkSecondaryTextColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkSecondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: darkSecondaryTextColor,
      indicatorColor: primaryColor,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkSurfaceColor,
      disabledColor: darkDividerColor,
      selectedColor: primaryColor.withAlpha(50),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkDividerColor),
      ),
      labelStyle: const TextStyle(color: darkTextColor),
      secondaryLabelStyle: const TextStyle(color: primaryColor),
      brightness: Brightness.dark,
    ),
  );
}