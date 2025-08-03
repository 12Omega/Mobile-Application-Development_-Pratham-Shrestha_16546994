import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/UserDto.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  final http.Client _client;
  String? _authToken;

  ApiService(this._client);

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<UserDto> getUserProfile(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserDto.fromJson(data['data']);
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<UserDto> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserDto.fromJson(data['data']);
      } else {
        throw Exception('Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to get user stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<UserDto> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return UserDto.fromJson(data['user']);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      );
    } finally {
      _authToken = null;
    }
  }
}