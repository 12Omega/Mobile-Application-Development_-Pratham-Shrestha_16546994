import 'package:flutter_test/flutter_test.dart';

// Import our Clean Architecture components
import 'lib/features/profile/domain/entities/user_profile.dart';
import 'lib/features/profile/data/models/user_profile_dto.dart';
import 'lib/core/error/failures.dart';
import 'lib/core/error/exceptions.dart';

void main() {
  group('Clean Architecture Integration Tests', () {
    test('UserProfile entity should be created correctly', () {
      // Arrange
      final userProfile = UserProfile(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Assert
      expect(userProfile.id, '123');
      expect(userProfile.name, 'John Doe');
      expect(userProfile.email, 'john@example.com');
      expect(userProfile.phone, '+1234567890');
    });

    test('UserProfileDto should convert to entity correctly', () {
      // Arrange
      final dto = UserProfileDto(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        createdAt: '2023-01-01T00:00:00.000Z',
        updatedAt: '2023-01-01T00:00:00.000Z',
      );

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.id, '123');
      expect(entity.name, 'John Doe');
      expect(entity.email, 'john@example.com');
      expect(entity.phone, '+1234567890');
    });

    test('Failures should be created correctly', () {
      // Arrange & Act
      const serverFailure = ServerFailure('Server error');
      const cacheFailure = CacheFailure('Cache error');
      const networkFailure = NetworkFailure('Network error');

      // Assert
      expect(serverFailure.message, 'Server error');
      expect(cacheFailure.message, 'Cache error');
      expect(networkFailure.message, 'Network error');
    });

    test('Exceptions should be created correctly', () {
      // Arrange & Act
      final serverException = ServerException('Server error');
      final cacheException = CacheException('Cache error');
      final networkException = NetworkException('Network error');

      // Assert
      expect(serverException.message, 'Server error');
      expect(cacheException.message, 'Cache error');
      expect(networkException.message, 'Network error');
    });

    test('UserProfile should support equality comparison', () {
      // Arrange
      final profile1 = UserProfile(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      final profile2 = UserProfile(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      final profile3 = UserProfile(
        id: '456',
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+0987654321',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Assert
      expect(profile1, equals(profile2));
      expect(profile1, isNot(equals(profile3)));
    });

    test('UserProfile copyWith should work correctly', () {
      // Arrange
      final originalProfile = UserProfile(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      final updatedProfile = originalProfile.copyWith(
        name: 'John Smith',
        email: 'johnsmith@example.com',
      );

      // Assert
      expect(updatedProfile.id, '123'); // unchanged
      expect(updatedProfile.name, 'John Smith'); // changed
      expect(updatedProfile.email, 'johnsmith@example.com'); // changed
      expect(updatedProfile.phone, '+1234567890'); // unchanged
    });
  });
}
