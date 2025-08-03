import '../model/User.dart';
import '../repository/UserRepository.dart';

class GetUserProfileUseCase {
  final UserRepository _userRepository;

  GetUserProfileUseCase(this._userRepository);

  Future<User> execute(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      return await _userRepository.getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
}

class UpdateUserProfileUseCase {
  final UserRepository _userRepository;

  UpdateUserProfileUseCase(this._userRepository);

  Future<User> execute(String userId, User user) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    // Validate user data
    if (user.name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }

    if (user.email.trim().isEmpty || !_isValidEmail(user.email)) {
      throw ArgumentError('Valid email is required');
    }

    if (user.phone.trim().isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    try {
      return await _userRepository.updateUserProfile(userId, user);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class GetUserStatsUseCase {
  final UserRepository _userRepository;

  GetUserStatsUseCase(this._userRepository);

  Future<Map<String, dynamic>> execute(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      return await _userRepository.getUserStats(userId);
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }
}

class LoginUseCase {
  final UserRepository _userRepository;

  LoginUseCase(this._userRepository);

  Future<User> execute(String email, String password) async {
    if (email.trim().isEmpty || !_isValidEmail(email)) {
      throw ArgumentError('Valid email is required');
    }

    if (password.trim().isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    try {
      return await _userRepository.login(email, password);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class LogoutUseCase {
  final UserRepository _userRepository;

  LogoutUseCase(this._userRepository);

  Future<void> execute() async {
    try {
      await _userRepository.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}