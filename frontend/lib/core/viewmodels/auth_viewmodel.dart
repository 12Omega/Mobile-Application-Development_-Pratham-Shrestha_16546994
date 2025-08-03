import 'package:flutter/material.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/services/auth_service.dart';
import 'package:parkease/core/services/navigation_service.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:parkease/ui/router.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  final NavigationService _navigationService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  AuthViewModel(
    this._authService,
    this._storageService,
    this._navigationService,
  ) {
    _checkAuthStatus();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Check if user is authenticated
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Get user from storage first for quick UI update
        _user = await _storageService.getUser();
        _isAuthenticated = true;
        notifyListeners();

        // Then fetch fresh data from API
        final result = await _authService.getCurrentUser();

        if (result['success']) {
          _user = result['user'];
          _isAuthenticated = true;
        } else {
          // Token might be expired or invalid
          _isAuthenticated = false;
          await _authService.logout();
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _errorMessage = 'Failed to check authentication status';
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licensePlate,
    required String vehicleType,
    String? color,
    String? model,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vehicleInfo = VehicleInfo(
        licensePlate: licensePlate,
        vehicleType: vehicleType,
        color: color ?? 'Not specified',
        model: model ?? 'Not specified',
      );

      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        vehicleInfo: vehicleInfo,
      );

      if (result['success']) {
        _user = result['user'];
        _isAuthenticated = true;
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
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        _user = result['user'];
        _isAuthenticated = true;
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
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();

    _navigationService.navigateTo(context, AppRoutes.login,
        params: null, queryParams: null);
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
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (!_isAuthenticated) return;

    try {
      final result = await _authService.getCurrentUser();

      if (result['success']) {
        _user = result['user'];
        notifyListeners();
      }
    } catch (e) {
      // Silent failure
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user is admin
  bool get isAdmin => _user?.role == 'admin';

  // Request password reset
  Future<bool> requestPasswordReset({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.requestPasswordReset(email: email);

      if (result['success']) {
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
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset password with token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (result['success']) {
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
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
