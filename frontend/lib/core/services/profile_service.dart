import 'dart:async';
import '../models/user_profile.dart';

class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Mock data for demonstration - replace with actual API calls
  UserProfile? _currentUser;
  List<Vehicle> _vehicles = [];
  List<PaymentMethod> _paymentMethods = [];
  NotificationSettings _notificationSettings = const NotificationSettings();

  // Initialize with mock data
  void _initializeMockData() {
    _currentUser = UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1 234 567 8900',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    _vehicles = [
      Vehicle(
        id: '1',
        make: 'Toyota',
        model: 'Camry',
        color: 'Silver',
        licensePlate: 'ABC 123',
        type: 'sedan',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Vehicle(
        id: '2',
        make: 'Honda',
        model: 'CR-V',
        color: 'Blue',
        licensePlate: 'XYZ 789',
        type: 'suv',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    _paymentMethods = [
      PaymentMethod(
        id: '1',
        type: PaymentMethodType.creditCard,
        displayName: 'Visa',
        lastFourDigits: '1234',
        expiryDate: '12/26',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      PaymentMethod(
        id: '2',
        type: PaymentMethodType.creditCard,
        displayName: 'MasterCard',
        lastFourDigits: '5678',
        expiryDate: '08/27',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // User Profile Methods
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser == null) {
      _initializeMockData();
    }

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  Future<UserProfile> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      updatedAt: DateTime.now(),
    );

    return _currentUser!;
  }

  // Vehicle Methods
  Future<List<Vehicle>> getUserVehicles() async {
    if (_vehicles.isEmpty) {
      _initializeMockData();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_vehicles);
  }

  Future<Vehicle> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required String type,
    bool isDefault = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final newVehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      make: make,
      model: model,
      color: color,
      licensePlate: licensePlate,
      type: type,
      isDefault: isDefault,
      createdAt: DateTime.now(),
    );

    // If this is set as default, update other vehicles
    if (isDefault) {
      _vehicles = _vehicles.map((v) => v.copyWith(isDefault: false)).toList();
    }

    _vehicles.add(newVehicle);
    return newVehicle;
  }

  Future<Vehicle> updateVehicle({
    required String vehicleId,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    String? type,
    bool? isDefault,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) {
      throw Exception('Vehicle not found');
    }

    final updatedVehicle = _vehicles[index].copyWith(
      make: make,
      model: model,
      color: color,
      licensePlate: licensePlate,
      type: type,
      isDefault: isDefault,
    );

    // If this is set as default, update other vehicles
    if (isDefault == true) {
      _vehicles = _vehicles
          .map((v) =>
              v.id == vehicleId ? updatedVehicle : v.copyWith(isDefault: false))
          .toList();
    } else {
      _vehicles[index] = updatedVehicle;
    }

    return updatedVehicle;
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _vehicles.removeWhere((v) => v.id == vehicleId);
  }

  // Payment Methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    if (_paymentMethods.isEmpty) {
      _initializeMockData();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_paymentMethods);
  }

  Future<PaymentMethod> addPaymentMethod({
    required PaymentMethodType type,
    required String displayName,
    required String lastFourDigits,
    String? expiryDate,
    bool isDefault = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final newPaymentMethod = PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      displayName: displayName,
      lastFourDigits: lastFourDigits,
      expiryDate: expiryDate,
      isDefault: isDefault,
      createdAt: DateTime.now(),
    );

    // If this is set as default, update other payment methods
    if (isDefault) {
      _paymentMethods =
          _paymentMethods.map((p) => p.copyWith(isDefault: false)).toList();
    }

    _paymentMethods.add(newPaymentMethod);
    return newPaymentMethod;
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _paymentMethods.removeWhere((p) => p.id == paymentMethodId);
  }

  // Notification Settings
  Future<NotificationSettings> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notificationSettings;
  }

  Future<NotificationSettings> updateNotificationSettings({
    bool? allNotifications,
    bool? parkingUpdates,
    bool? bookingReminders,
    bool? promotionalOffers,
    bool? securityAlerts,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _notificationSettings = _notificationSettings.copyWith(
      allNotifications: allNotifications,
      parkingUpdates: parkingUpdates,
      bookingReminders: bookingReminders,
      promotionalOffers: promotionalOffers,
      securityAlerts: securityAlerts,
    );

    return _notificationSettings;
  }

  // Support Methods
  Future<void> sendSupportMessage({
    required String subject,
    required String message,
    String? userEmail,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // In a real app, this would send the message to your support system
    print('Support message sent:');
    print('Subject: $subject');
    print('Message: $message');
    print('User Email: ${userEmail ?? _currentUser?.email}');
  }

  // Logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Clear all cached data
    _currentUser = null;
    _vehicles.clear();
    _paymentMethods.clear();
    _notificationSettings = const NotificationSettings();
  }

  // Real API methods (commented out - implement when you have a backend)
  /*
  Future<UserProfile?> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> _getAuthToken() async {
    // Get auth token from secure storage
    return 'your_auth_token_here';
  }
  */
}
