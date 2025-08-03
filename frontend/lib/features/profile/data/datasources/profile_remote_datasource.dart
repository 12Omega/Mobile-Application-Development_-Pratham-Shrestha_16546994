import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDto> getUserProfile(String userId);
  Future<UserProfileDto> updateUserProfile(String userId, Map<String, dynamic> updateData);
  Future<void> deleteUserProfile(String userId);
  Future<UserProfileDto> uploadProfileImage(String userId, String imagePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileDto> getUserProfile(String userId) async {
    try {
      final response = await apiClient.get('/users/$userId/profile');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserProfileDto.fromJson(jsonData['data']);
      } else {
        throw ServerException('Failed to get user profile');
      }
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<UserProfileDto> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      final response = await apiClient.put(
        '/users/$userId/profile',
        body: json.encode(updateData),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserProfileDto.fromJson(jsonData['data']);
      } else {
        throw ServerException('Failed to update user profile');
      }
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      final response = await apiClient.delete('/users/$userId/profile');
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to delete user profile');
      }
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<UserProfileDto> uploadProfileImage(String userId, String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiClient.baseUrl}/users/$userId/profile/image'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.headers.addAll(apiClient.headers);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserProfileDto.fromJson(jsonData['data']);
      } else {
        throw ServerException('Failed to upload profile image');
      }
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }
}