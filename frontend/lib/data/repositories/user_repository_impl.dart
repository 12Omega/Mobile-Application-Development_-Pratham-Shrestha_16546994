import '../../core/models/user.dart';
import '../../core/models/notification_settings.dart';
import '../../core/services/user_repository.dart';
import '../remote/api_service.dart';
import '../local/local_storage_service.dart';
import '../models/user_dto.dart';
import '../models/notification_settings_dto.dart' as notification_dto;

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  UserRepositoryImpl(this._apiService, this._localStorageService);

  @override
  Future<User> getUserProfile(String userId) async {
    try {
      // Try to get from cache first
      final cachedUser =
          await _localStorageService.getCachedUserProfile(userId);
      if (cachedUser != null) {
        return _mapUserDtoToUser(cachedUser);
      }

      // If not in cache, fetch from API
      final userDto = await _apiService.getUserProfile(userId);

      // Cache the result
      await _localStorageService.cacheUserProfile(userDto);

      return _mapUserDtoToUser(userDto);
    } catch (e) {
      // If API fails, try to return cached data
      final cachedUser =
          await _localStorageService.getCachedUserProfile(userId);
      if (cachedUser != null) {
        return _mapUserDtoToUser(cachedUser);
      }
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
      };

      final userDto = await _apiService.updateUserProfile(userId, updateData);

      // Update cache
      await _localStorageService.cacheUserProfile(userDto);

      return _mapUserDtoToUser(userDto);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String userId) async {
    try {
      final settingsDto = await _apiService.getNotificationSettings(userId);
      return _mapNotificationSettingsDtoToModel(settingsDto);
    } catch (e) {
      throw Exception('Failed to get notification settings: $e');
    }
  }

  @override
  Future<NotificationSettings> updateNotificationSettings(
      String userId, NotificationSettings settings) async {
    try {
      final updateData = {
        'pushNotifications': settings.pushNotifications,
        'emailNotifications': settings.emailNotifications,
        'smsNotifications': settings.smsNotifications,
        'parkingReminders': settings.parkingReminders,
        'paymentAlerts': settings.paymentAlerts,
        'promotionalOffers': settings.promotionalOffers,
      };

      final settingsDto =
          await _apiService.updateNotificationSettings(userId, updateData);
      return _mapNotificationSettingsDtoToModel(settingsDto);
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  @override
  Future<void> sendSupportMessage(
      String userId, String subject, String message) async {
    try {
      final messageData = {
        'subject': subject,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _apiService.sendSupportMessage(userId, messageData);
    } catch (e) {
      throw Exception('Failed to send support message: $e');
    }
  }

  User _mapUserDtoToUser(UserDto dto) {
    return User(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(dto.updatedAt) ?? DateTime.now(),
    );
  }

  NotificationSettings _mapNotificationSettingsDtoToModel(
      notification_dto.NotificationSettingsDto dto) {
    return NotificationSettings(
      id: dto.id,
      userId: dto.userId,
      pushNotifications: dto.pushNotifications,
      emailNotifications: dto.emailNotifications,
      smsNotifications: dto.smsNotifications,
      parkingReminders: dto.parkingReminders,
      paymentAlerts: dto.paymentAlerts,
      promotionalOffers: dto.promotionalOffers,
      updatedAt: dto.updatedAt,
    );
  }
}
