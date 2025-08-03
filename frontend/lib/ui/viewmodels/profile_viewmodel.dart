import 'package:flutter/foundation.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  // State variables
  UserProfile? _currentUser;
  List<Vehicle> _vehicles = [];
  List<PaymentMethod> _paymentMethods = [];
  NotificationSettings _notificationSettings = const NotificationSettings();

  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get currentUser => _currentUser;
  List<Vehicle> get vehicles => _vehicles;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  NotificationSettings get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  Vehicle? get defaultVehicle =>
      _vehicles.where((v) => v.isDefault).firstOrNull;
  PaymentMethod? get defaultPaymentMethod =>
      _paymentMethods.where((p) => p.isDefault).firstOrNull;
  String get userInitials {
    if (_currentUser?.name.isEmpty ?? true) return 'U';
    final nameParts = _currentUser!.name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else {
      return nameParts[0][0];
    }
  }

  // Initialize profile data
  Future<void> initialize() async {
    await Future.wait([
      loadUserProfile(),
      loadVehicles(),
      loadPaymentMethods(),
      loadNotificationSettings(),
    ]);
  }

  // User Profile Methods
  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _currentUser = await _profileService.getCurrentUser();
      _clearError();
    } catch (e) {
      _setError('Failed to load user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _currentUser = await _profileService.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to update profile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Vehicle Methods
  Future<void> loadVehicles() async {
    try {
      _vehicles = await _profileService.getUserVehicles();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load vehicles: $e');
    }
  }

  Future<void> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required String type,
    bool isDefault = false,
  }) async {
    try {
      _setLoading(true);
      final newVehicle = await _profileService.addVehicle(
        make: make,
        model: model,
        color: color,
        licensePlate: licensePlate,
        type: type,
        isDefault: isDefault,
      );

      // Update local list
      if (isDefault) {
        _vehicles = _vehicles.map((v) => v.copyWith(isDefault: false)).toList();
      }
      _vehicles.add(newVehicle);
      _clearError();
    } catch (e) {
      _setError('Failed to add vehicle: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVehicle({
    required String vehicleId,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    String? type,
    bool? isDefault,
  }) async {
    try {
      _setLoading(true);
      final updatedVehicle = await _profileService.updateVehicle(
        vehicleId: vehicleId,
        make: make,
        model: model,
        color: color,
        licensePlate: licensePlate,
        type: type,
        isDefault: isDefault,
      );

      // Update local list
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        if (isDefault == true) {
          _vehicles = _vehicles
              .map((v) => v.id == vehicleId
                  ? updatedVehicle
                  : v.copyWith(isDefault: false))
              .toList();
        } else {
          _vehicles[index] = updatedVehicle;
        }
      }
      _clearError();
    } catch (e) {
      _setError('Failed to update vehicle: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      _setLoading(true);
      await _profileService.deleteVehicle(vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      _clearError();
    } catch (e) {
      _setError('Failed to delete vehicle: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Payment Methods
  Future<void> loadPaymentMethods() async {
    try {
      _paymentMethods = await _profileService.getPaymentMethods();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment methods: $e');
    }
  }

  Future<void> addPaymentMethod({
    required PaymentMethodType type,
    required String displayName,
    required String lastFourDigits,
    String? expiryDate,
    bool isDefault = false,
  }) async {
    try {
      _setLoading(true);
      final newPaymentMethod = await _profileService.addPaymentMethod(
        type: type,
        displayName: displayName,
        lastFourDigits: lastFourDigits,
        expiryDate: expiryDate,
        isDefault: isDefault,
      );

      // Update local list
      if (isDefault) {
        _paymentMethods =
            _paymentMethods.map((p) => p.copyWith(isDefault: false)).toList();
      }
      _paymentMethods.add(newPaymentMethod);
      _clearError();
    } catch (e) {
      _setError('Failed to add payment method: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      _setLoading(true);
      await _profileService.deletePaymentMethod(paymentMethodId);
      _paymentMethods.removeWhere((p) => p.id == paymentMethodId);
      _clearError();
    } catch (e) {
      _setError('Failed to delete payment method: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Notification Settings
  Future<void> loadNotificationSettings() async {
    try {
      _notificationSettings = await _profileService.getNotificationSettings();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load notification settings: $e');
    }
  }

  Future<void> updateNotificationSettings({
    bool? allNotifications,
    bool? parkingUpdates,
    bool? bookingReminders,
    bool? promotionalOffers,
    bool? securityAlerts,
  }) async {
    try {
      _notificationSettings = await _profileService.updateNotificationSettings(
        allNotifications: allNotifications,
        parkingUpdates: parkingUpdates,
        bookingReminders: bookingReminders,
        promotionalOffers: promotionalOffers,
        securityAlerts: securityAlerts,
      );
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update notification settings: $e');
      rethrow;
    }
  }

  // Support
  Future<void> sendSupportMessage({
    required String subject,
    required String message,
  }) async {
    try {
      _setLoading(true);
      await _profileService.sendSupportMessage(
        subject: subject,
        message: message,
        userEmail: _currentUser?.email,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to send support message: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _profileService.logout();

      // Clear local state
      _currentUser = null;
      _vehicles.clear();
      _paymentMethods.clear();
      _notificationSettings = const NotificationSettings();
      _clearError();
    } catch (e) {
      _setError('Failed to logout: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Validation helpers
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  bool isValidLicensePlate(String licensePlate) {
    return licensePlate.trim().isNotEmpty && licensePlate.length >= 2;
  }

  // Format helpers
  String formatCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  String formatExpiryDate(String expiry) {
    final cleaned = expiry.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }
}
