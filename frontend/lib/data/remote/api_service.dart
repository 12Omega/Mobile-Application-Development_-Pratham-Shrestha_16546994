import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_dto.dart' as user_models;
import '../models/vehicle_dto.dart' as vehicle_models;
import '../models/payment_method_dto.dart' as payment_models;
import '../models/notification_settings_dto.dart' as notification_models;
import '../../core/utils/app_exceptions.dart';

abstract class ApiService {
  Future<user_models.UserDto> getUserProfile(String userId);
  Future<user_models.UserDto> updateUserProfile(
      String userId, Map<String, dynamic> data);
  Future<List<vehicle_models.VehicleDto>> getUserVehicles(String userId);
  Future<vehicle_models.VehicleDto> addVehicle(
      String userId, Map<String, dynamic> vehicleData);
  Future<vehicle_models.VehicleDto> updateVehicle(
      String vehicleId, Map<String, dynamic> vehicleData);
  Future<void> deleteVehicle(String vehicleId);
  Future<List<payment_models.PaymentMethodDto>> getPaymentMethods(
      String userId);
  Future<payment_models.PaymentMethodDto> addPaymentMethod(
      String userId, Map<String, dynamic> paymentData);
  Future<void> deletePaymentMethod(String paymentMethodId);
  Future<notification_models.NotificationSettingsDto> getNotificationSettings(
      String userId);
  Future<notification_models.NotificationSettingsDto>
      updateNotificationSettings(String userId, Map<String, dynamic> settings);
  Future<void> sendSupportMessage(
      String userId, Map<String, dynamic> messageData);
}

class ApiServiceImpl implements ApiService {
  static const String _baseUrl = 'https://api.parkease.com/v1';
  final http.Client _client;
  String? _authToken;

  ApiServiceImpl({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  @override
  Future<user_models.UserDto> getUserProfile(String userId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/users/$userId/profile'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return user_models.UserDto.fromJson(data);
      } else {
        throw ServerException(
            'Failed to load user profile', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<user_models.UserDto> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/users/$userId/profile'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return user_models.UserDto.fromJson(responseData);
      } else {
        throw ServerException(
            'Failed to update user profile', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<List<vehicle_models.VehicleDto>> getUserVehicles(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/users/$userId/vehicles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((item) => vehicle_models.VehicleDto.fromJson(item))
            .toList();
      } else {
        throw ServerException('Failed to load vehicles', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<vehicle_models.VehicleDto> addVehicle(
      String userId, Map<String, dynamic> vehicleData) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/users/$userId/vehicles'),
        headers: _headers,
        body: json.encode(vehicleData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return vehicle_models.VehicleDto.fromJson(data);
      } else {
        throw ServerException('Failed to add vehicle', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<vehicle_models.VehicleDto> updateVehicle(
      String vehicleId, Map<String, dynamic> vehicleData) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
        headers: _headers,
        body: json.encode(vehicleData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return vehicle_models.VehicleDto.fromJson(data);
      } else {
        throw ServerException('Failed to update vehicle', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw ServerException('Failed to delete vehicle', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<List<payment_models.PaymentMethodDto>> getPaymentMethods(
      String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/users/$userId/payment-methods'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((item) => payment_models.PaymentMethodDto.fromJson(item))
            .toList();
      } else {
        throw ServerException(
            'Failed to load payment methods', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<payment_models.PaymentMethodDto> addPaymentMethod(
      String userId, Map<String, dynamic> paymentData) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/users/$userId/payment-methods'),
        headers: _headers,
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return payment_models.PaymentMethodDto.fromJson(data);
      } else {
        throw ServerException(
            'Failed to add payment method', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/payment-methods/$paymentMethodId'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw ServerException(
            'Failed to delete payment method', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<notification_models.NotificationSettingsDto> getNotificationSettings(
      String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/users/$userId/notification-settings'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return notification_models.NotificationSettingsDto.fromJson(data);
      } else {
        throw ServerException(
            'Failed to load notification settings', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<notification_models.NotificationSettingsDto>
      updateNotificationSettings(
          String userId, Map<String, dynamic> settings) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/users/$userId/notification-settings'),
        headers: _headers,
        body: json.encode(settings),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return notification_models.NotificationSettingsDto.fromJson(data);
      } else {
        throw ServerException(
            'Failed to update notification settings', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on FormatException {
      throw ServerException('Invalid response format', 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  @override
  Future<void> sendSupportMessage(
      String userId, Map<String, dynamic> messageData) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/support/messages'),
        headers: _headers,
        body: json.encode({
          'userId': userId,
          ...messageData,
        }),
      );

      if (response.statusCode != 201) {
        throw ServerException(
            'Failed to send support message', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e', 500);
    }
  }

  void dispose() {
    _client.close();
  }
}
