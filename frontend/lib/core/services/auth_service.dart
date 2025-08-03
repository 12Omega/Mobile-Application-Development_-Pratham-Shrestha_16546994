import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/services/api_service.dart';
import 'package:parkease/core/services/storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required VehicleInfo vehicleInfo,
  }) async {
    // Mock registration for testing - create a user with provided data
    try {
      final mockUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        vehicleInfo: vehicleInfo,
        preferences: UserPreferences(
          notifications: true,
          theme: 'system',
        ),
        role: 'user',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';

      // Save token and user data
      await _storageService.setAuthToken(mockToken);
      await _storageService.setUser(mockUser);

      return {
        'success': true,
        'user': mockUser,
        'token': mockToken,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }

    // Real API call (commented out for development)
    /*
    try {
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'vehicleInfo': vehicleInfo.toJson(),
      });

      if (response['success'] == true) {
        final token = response['data']['token'];
        final user = User.fromJson(response['data']['user']);

        // Save token and user data
        await _storageService.setAuthToken(token);
        await _storageService.setUser(user);

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Registration failed',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
    */
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Mock authentication for testing
    if (email == 'testuser@example.com' && password == 'password123') {
      final mockUser = User(
        id: 'mock_user_123',
        name: 'Test User',
        email: email,
        phone: '+1234567890',
        vehicleInfo: VehicleInfo(
          licensePlate: 'ABC123',
          vehicleType: 'sedan',
          model: 'Camry',
          color: 'Blue',
        ),
        preferences: UserPreferences(
          notifications: true,
          theme: 'system',
        ),
        role: 'user',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      const mockToken = 'mock_jwt_token_123456789';

      // Save token and user data
      await _storageService.setAuthToken(mockToken);
      await _storageService.setUser(mockUser);

      return {
        'success': true,
        'user': mockUser,
        'token': mockToken,
      };
    }

    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        final token = response['data']['token'];
        final user = User.fromJson(response['data']['user']);

        // Save token and user data
        await _storageService.setAuthToken(token);
        await _storageService.setUser(user);

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid credentials. Try: testuser@example.com / password123',
      };
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');

      if (response['success'] == true) {
        final user = User.fromJson(response['data']['user']);

        // Update stored user data
        await _storageService.setUser(user);

        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to get user profile',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    VehicleInfo? vehicleInfo,
    UserPreferences? preferences,
  }) async {
    try {
      final data = {};

      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (vehicleInfo != null) data['vehicleInfo'] = vehicleInfo.toJson();
      if (preferences != null) data['preferences'] = preferences.toJson();

      final response = await _apiService.put('/auth/profile', data: data);

      if (response['success'] == true) {
        final user = User.fromJson(response['data']['user']);

        // Update stored user data
        await _storageService.setUser(user);

        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update profile',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storageService.clearAuthToken();
    await _storageService.clearUser();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    return await _storageService.getUser();
  }

  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ??
              'Password reset instructions sent to your email',
        };
      } else {
        return {
          'success': false,
          'message':
              response['message'] ?? 'Failed to send password reset email',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Reset password with token
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to reset password',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}
