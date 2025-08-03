import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_dto.dart';
import '../models/vehicle_dto.dart' as vehicle_models;
import '../models/payment_method_dto.dart' as payment_models;
import '../models/notification_settings_dto.dart' as notification_models;

abstract class LocalStorageService {
  Future<void> cacheUserProfile(UserDto user);
  Future<UserDto?> getCachedUserProfile(String userId);
  Future<void> cacheUserVehicles(
      String userId, List<vehicle_models.VehicleDto> vehicles);
  Future<List<vehicle_models.VehicleDto>?> getCachedUserVehicles(String userId);
  Future<void> cachePaymentMethods(
      String userId, List<payment_models.PaymentMethodDto> paymentMethods);
  Future<List<payment_models.PaymentMethodDto>?> getCachedPaymentMethods(
      String userId);
  Future<void> cacheNotificationSettings(
      notification_models.NotificationSettingsDto settings);
  Future<notification_models.NotificationSettingsDto?>
      getCachedNotificationSettings(String userId);
  Future<void> clearCache();
  Future<void> clearUserCache(String userId);
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _userProfileBox = 'user_profiles';
  static const String _vehiclesBox = 'user_vehicles';
  static const String _paymentMethodsBox = 'payment_methods';
  static const String _notificationSettingsBox = 'notification_settings';

  Box<String>? _userProfilesBox;
  Box<String>? _vehiclesBoxInstance;
  Box<String>? _paymentMethodsBoxInstance;
  Box<String>? _notificationSettingsBoxInstance;

  Future<void> _initBoxes() async {
    _userProfilesBox ??= await Hive.openBox<String>(_userProfileBox);
    _vehiclesBoxInstance ??= await Hive.openBox<String>(_vehiclesBox);
    _paymentMethodsBoxInstance ??=
        await Hive.openBox<String>(_paymentMethodsBox);
    _notificationSettingsBoxInstance ??=
        await Hive.openBox<String>(_notificationSettingsBox);
  }

  @override
  Future<void> cacheUserProfile(UserDto user) async {
    await _initBoxes();
    final userJson = json.encode(user.toJson());
    await _userProfilesBox!.put(user.id, userJson);
  }

  @override
  Future<UserDto?> getCachedUserProfile(String userId) async {
    await _initBoxes();
    final userJson = _userProfilesBox!.get(userId);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserDto.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<void> cacheUserVehicles(
      String userId, List<vehicle_models.VehicleDto> vehicles) async {
    await _initBoxes();
    final vehiclesJson = json.encode(vehicles.map((v) => v.toJson()).toList());
    await _vehiclesBoxInstance!.put(userId, vehiclesJson);
  }

  @override
  Future<List<vehicle_models.VehicleDto>?> getCachedUserVehicles(
      String userId) async {
    await _initBoxes();
    final vehiclesJson = _vehiclesBoxInstance!.get(userId);
    if (vehiclesJson != null) {
      final vehiclesList = json.decode(vehiclesJson) as List;
      return vehiclesList
          .map((v) =>
              vehicle_models.VehicleDto.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> cachePaymentMethods(String userId,
      List<payment_models.PaymentMethodDto> paymentMethods) async {
    await _initBoxes();
    final paymentMethodsJson =
        json.encode(paymentMethods.map((p) => p.toJson()).toList());
    await _paymentMethodsBoxInstance!.put(userId, paymentMethodsJson);
  }

  @override
  Future<List<payment_models.PaymentMethodDto>?> getCachedPaymentMethods(
      String userId) async {
    await _initBoxes();
    final paymentMethodsJson = _paymentMethodsBoxInstance!.get(userId);
    if (paymentMethodsJson != null) {
      final paymentMethodsList = json.decode(paymentMethodsJson) as List;
      return paymentMethodsList
          .map((p) => payment_models.PaymentMethodDto.fromJson(
              p as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> cacheNotificationSettings(
      notification_models.NotificationSettingsDto settings) async {
    await _initBoxes();
    final settingsJson = json.encode(settings.toJson());
    await _notificationSettingsBoxInstance!
        .put('notification_settings', settingsJson);
  }

  @override
  Future<notification_models.NotificationSettingsDto?>
      getCachedNotificationSettings(String userId) async {
    await _initBoxes();
    final settingsJson = _notificationSettingsBoxInstance!.get(userId);
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return notification_models.NotificationSettingsDto.fromJson(settingsMap);
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _initBoxes();
    await _userProfilesBox!.clear();
    await _vehiclesBoxInstance!.clear();
    await _paymentMethodsBoxInstance!.clear();
    await _notificationSettingsBoxInstance!.clear();
  }

  @override
  Future<void> clearUserCache(String userId) async {
    await _initBoxes();
    await _userProfilesBox!.delete(userId);
    await _vehiclesBoxInstance!.delete(userId);
    await _paymentMethodsBoxInstance!.delete(userId);
    await _notificationSettingsBoxInstance!.delete(userId);
  }
}
