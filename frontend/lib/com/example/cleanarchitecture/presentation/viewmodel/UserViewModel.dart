import 'package:flutter/material.dart';
import '../../domain/model/User.dart';
import '../../domain/usecase/GetUserProfileUseCase.dart';

class UserViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final GetUserStatsUseCase _getUserStatsUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  User? _user;
  Map<String, dynamic>? _userStats;
  bool _isLoading = false;
  String? _errorMessage;

  UserViewModel(
    this._getUserProfileUseCase,
    this._updateUserProfileUseCase,
    this._getUserStatsUseCase,
    this._loginUseCase,
    this._logoutUseCase,
  );

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user profile
  Future<void> loadUserProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _getUserProfileUseCase.execute(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(String userId, User updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _updateUserProfileUseCase.execute(userId, updatedUser);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load user stats
  Future<void> loadUserStats(String userId) async {
    try {
      _userStats = await _getUserStatsUseCase.execute(userId);
      notifyListeners();
    } catch (e) {
      // Silent failure for stats
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _loginUseCase.execute(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _logoutUseCase.execute();
      _user = null;
      _userStats = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update theme preference
  Future<void> updateThemePreference(bool isDarkMode) async {
    if (_user == null) return;

    final preferences = _user!.preferences?.copyWith(isDarkMode: isDarkMode) ??
        UserPreferences(
          notifications: true,
          theme: isDarkMode ? 'dark' : 'light',
        );

    final updatedUser = _user!.copyWith(preferences: preferences);
    await updateUserProfile(_user!.id, updatedUser);
  }

  // Update notification preference
  Future<void> updateNotificationPreference(bool enabled) async {
    if (_user == null) return;

    final preferences = _user!.preferences?.copyWith(notificationsEnabled: enabled) ??
        UserPreferences(
          notifications: enabled,
          theme: 'system',
        );

    final updatedUser = _user!.copyWith(preferences: preferences);
    await updateUserProfile(_user!.id, updatedUser);
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

    final updatedUser = _user!.copyWith(vehicleInfo: vehicleInfo);
    return await updateUserProfile(_user!.id, updatedUser);
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    if (_user != null) {
      await loadUserProfile(_user!.id);
      await loadUserStats(_user!.id);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }
}