import '../model/User.dart';

abstract class UserRepository {
  Future<User> getUserProfile(String userId);
  Future<User> updateUserProfile(String userId, User user);
  Future<Map<String, dynamic>> getUserStats(String userId);
  Future<User> login(String email, String password);
  Future<void> logout();
}