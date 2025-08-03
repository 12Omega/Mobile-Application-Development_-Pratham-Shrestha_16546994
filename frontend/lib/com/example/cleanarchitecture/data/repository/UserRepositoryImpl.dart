import '../../domain/model/User.dart';
import '../../domain/repository/UserRepository.dart';
import '../remote/ApiService.dart';
import '../model/UserDto.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<User> getUserProfile(String userId) async {
    try {
      final userDto = await _apiService.getUserProfile(userId);
      return _mapUserDtoToUser(userDto);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<User> updateUserProfile(String userId, User user) async {
    try {
      final updateData = {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'vehicleInfo': user.vehicleInfo?.toJson(),
        'preferences': user.preferences?.toJson(),
      };
      
      final userDto = await _apiService.updateUserProfile(userId, updateData);
      return _mapUserDtoToUser(userDto);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      return await _apiService.getUserStats(userId);
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final userDto = await _apiService.login(email, password);
      return _mapUserDtoToUser(userDto);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  User _mapUserDtoToUser(UserDto dto) {
    return User(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      vehicleInfo: dto.vehicleInfo != null 
          ? VehicleInfo(
              licensePlate: dto.vehicleInfo!.licensePlate,
              vehicleType: dto.vehicleInfo!.vehicleType,
              color: dto.vehicleInfo!.color,
              model: dto.vehicleInfo!.model,
            )
          : null,
      preferences: dto.preferences != null
          ? UserPreferences(
              notifications: dto.preferences!.notifications,
              theme: dto.preferences!.theme,
            )
          : null,
      role: dto.role,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}