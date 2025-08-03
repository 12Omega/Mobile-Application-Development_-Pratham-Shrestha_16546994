import 'package:flutter/material.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/services/auth_service.dart';
import 'package:parkease/core/services/booking_service.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:parkease/core/services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final BookingService _bookingService;
  final StorageService _storageService;
  final ApiService _apiService;

  User? _user;
  Map<String, dynamic>? _userStats;
  List<Booking> _recentBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProfileViewModel(
    this._authService,
    this._bookingService,
    this._storageService,
    this._apiService,
  ) {
    _initialize();
  }

  User? get user => _user;
  Map<String, dynamic>? get userStats => _userStats;
  List<Booking> get recentBookings => _recentBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize view model
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user data
      final userData = await _authService.getCurrentUser();
      if (userData['success']) {
        _user = userData['user'];
      }

      // Load user stats and bookings
      await Future.wait([
        _loadUserStats(),
        _loadRecentBookings(),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user stats
  Future<void> _loadUserStats() async {
    try {
      final response = await _apiService.getUserStats();

      if (response['success']) {
        _userStats = response['data'];
      }
    } catch (e) {
      // Silent failure
    }
  }

  // Load recent bookings
  Future<void> _loadRecentBookings() async {
    try {
      // Try to get cached bookings first
      final cachedBookings = await _storageService.getRecentBookings();
      if (cachedBookings.isNotEmpty) {
        _recentBookings = cachedBookings;
        notifyListeners();
      }

      // Then fetch fresh data
      final result = await _bookingService.getRecentBookings();

      if (result['success']) {
        _recentBookings = result['bookings'];

        // Cache the bookings
        await _storageService.saveRecentBookings(_recentBookings);
      }
    } catch (e) {
      // Silent failure
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    VehicleInfo? vehicleInfo,
    UserPreferences? preferences,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        name: name,
        phone: phone,
        vehicleInfo: vehicleInfo,
        preferences: preferences,
      );

      if (result['success']) {
        _user = result['user'];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update theme preference
  Future<void> updateThemePreference(bool isDarkMode) async {
    if (_user == null) return;

    final preferences = _user!.preferences.copyWith(
      isDarkMode: isDarkMode,
    );

    await updateProfile(preferences: preferences);
  }

  // Update notification preference
  Future<void> updateNotificationPreference(bool enabled) async {
    if (_user == null) return;

    final preferences = _user!.preferences.copyWith(
      notificationsEnabled: enabled,
    );

    await updateProfile(preferences: preferences);
  }

  // Update vehicle info
  Future<bool> updateVehicleInfo({
    required String licensePlate,
    required String vehicleType,
    String? color,
    String? model,
  }) async {
    if (_user == null) return false;

    final vehicleInfo = VehicleInfo(
      licensePlate: licensePlate,
      vehicleType: vehicleType,
      color: color,
      model: model,
    );

    return await updateProfile(vehicleInfo: vehicleInfo);
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Refresh user data
      final userResult = await _authService.getCurrentUser();
      if (userResult['success']) {
        _user = userResult['user'];
      }

      // Load user stats and bookings
      await Future.wait([
        _loadUserStats(),
        _loadRecentBookings(),
      ]);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh data';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    await _authService.logout();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.getUserStats();

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Method for profile_screen.dart
  Future<void> refreshProfileData() async {
    await refreshProfile();
  }
}
