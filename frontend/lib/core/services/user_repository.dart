// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports
// Use Clean Architecture version in features/profile/ instead

import '../models/user.dart';
import '../models/notification_settings.dart';

abstract class UserRepository {
  Future<User> getUserProfile(String userId);
  Future<User> updateUserProfile(String userId, User user);
  Future<NotificationSettings> getNotificationSettings(String userId);
  Future<NotificationSettings> updateNotificationSettings(
      String userId, NotificationSettings settings);
  Future<void> sendSupportMessage(
      String userId, String subject, String message);
}
