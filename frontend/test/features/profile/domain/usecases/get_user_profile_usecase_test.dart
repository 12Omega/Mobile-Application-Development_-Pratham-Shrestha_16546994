import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:parkease/core/error/failures.dart';
import 'package:parkease/features/profile/domain/entities/user_profile.dart';
import 'package:parkease/features/profile/domain/repositories/profile_repository.dart';
import 'package:parkease/features/profile/domain/usecases/get_user_profile_usecase.dart';

import 'get_user_profile_usecase_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetUserProfileUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetUserProfileUseCase(mockRepository);
  });

  const testUserId = '123';
  final testUserProfile = UserProfile(
    id: testUserId,
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1234567890',
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  group('GetUserProfileUseCase', () {
    test('should get user profile from repository', () async {
      // Arrange
      when(mockRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => Right(testUserProfile));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result, Right(testUserProfile));
      verify(mockRepository.getUserProfile(testUserId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(mockRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getUserProfile(testUserId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}