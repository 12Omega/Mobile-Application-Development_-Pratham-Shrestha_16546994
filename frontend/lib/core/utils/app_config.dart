import 'package:flutter/foundation.dart';

class AppConfig {
  // API configuration
  static const String apiBaseUrl =
      'http://10.0.2.2:3000/api'; // For Android emulator
  // static const String apiBaseUrl = 'http://localhost:3000/api'; // For iOS simulator
  // static const String apiBaseUrl = 'https://api.parkease.com/api'; // Production

  // Google Maps API key - For development, we'll use a mock implementation
  static const String googleMapsApiKey = 'DEVELOPMENT_MODE';

  // Stripe configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';

  // App version
  static const String appVersion = '1.0.0';

  // Debug mode
  static bool get isDebug => kDebugMode;

  // Timeout durations
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Cache configuration
  static const int cacheDuration = 60 * 60 * 24; // 24 hours in seconds

  // Location configuration
  static const int locationUpdateInterval = 10000; // 10 seconds in milliseconds
  static const double defaultMapZoom = 15.0;
  static const double defaultSearchRadius = 5000; // 5km in meters
  
  // Map performance settings
  static const bool enableMapLiteMode = true; // Use lite mode for better performance
  static const bool enableMapToolbar = false;
  static const bool enableMapZoomControls = false;

  // Pagination
  static const int defaultPageSize = 10;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
