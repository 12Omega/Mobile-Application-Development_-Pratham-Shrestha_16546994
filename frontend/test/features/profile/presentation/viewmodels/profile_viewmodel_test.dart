import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:parkease/core/error/failures.dart';
import 'package:parkease/features/profile/domain/entities/user_profile.dart';
import 'package:parkease/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:parkease/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:parkease/features/profile/presentation/viewmodels/profile_viewmodel.dart';

import 'profile_viewmodel_test.mocks.dart';

@GenerateMocks([
  GetUserProfileUseCase,
  UpdateUserProfileUseCase,
])
void main() {
  late ProfileViewModel viewModel;
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;
  late MockUpdateUserProfileUseCase mockUpdateUserProfileUseCase;

  setUp(() {
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    mockUpdateUserProfileUseCase = MockUpdateUserProfileUseCase();
    viewModel = ProfileViewModel(
      getUserProfileUseCase: mockGetUserProfileUseCase,
      updateUserProfileUseCase: mockUpdateUserProfileUseCase,
    );
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

  group('ProfileViewModel', () {
    group('loadUserProfile', () {
      test('should load user profile successfully', () async {
        // Arrange
        when(mockGetUserProfileUseCase(testUserId))
            .thenAnswer((_) async => Right(testUserProfile));

        // Act
        await viewModel.loadUserProfile(testUserId);

        // Assert
        expect(viewModel.userProfile, testUserProfile);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        verify(mockGetUserProfileUseCase(testUserId));
      });

      test('should set error message when loading fails', () async {
        // Arrange
        const failure = ServerFailure('Server error');
        when(mockGetUserProfileUseCase(testUserId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        await viewModel.loadUserProfile(testUserId);

        // Assert
        expect(viewModel.userProfile, null);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Server error occurred');
        verify(mockGetUserProfileUseCase(testUserId));
      });

      test('should set loading state correctly', () async {
        // Arrange
        when(mockGetUserProfileUseCase(testUserId))
            .thenAnswer((_) async => Right(testUserProfile));

        // Act & Assert
        expect(viewModel.isLoading, false);
        
        final future = viewModel.loadUserProfile(testUserId);
        expect(viewModel.isLoading, true);
        
        await future;
        expect(viewModel.isLoading, false);
      });
    });

    group('updateProfile', () {
      const updateName = 'Jane Doe';
      const updatePhone = '+0987654321';

      test('should update profile successfully', () async {
        // Arrange
        final updatedProfile = testUserProfile.copyWith(
          name: updateName,
          phone: updatePhone,
        );
        
        when(mockUpdateUserProfileUseCase(any))
            .thenAnswer((_) async => Right(updatedProfile));

        // Act
        await viewModel.updateProfile(
          userId: testUserId,
          name: updateName,
          phone: updatePhone,
        );

        // Assert
        expect(viewModel.userProfile, updatedProfile);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        
        final captured = verify(mockUpdateUserProfileUseCase(captureAny)).captured;
        final params = captured.first as UpdateUserProfileParams;
        expect(params.userId, testUserId);
        expect(params.updateData['name'], updateName);
        expect(params.updateData['phone'], updatePhone);
      });

      test('should set error message when update fails', () async {
        // Arrange
        const failure = NetworkFailure('Network error');
        when(mockUpdateUserProfileUseCase(any))
            .thenAnswer((_) async => const Left(failure));

        // Act
        await viewModel.updateProfile(
          userId: testUserId,
          name: updateName,
        );

        // Assert
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Network error occurred');
        verify(mockUpdateUserProfileUseCase(any));
      });

      test('should only include provided fields in update data', () async {
        // Arrange
        when(mockUpdateUserProfileUseCase(any))
            .thenAnswer((_) async => Right(testUserProfile));

        // Act
        await viewModel.updateProfile(
          userId: testUserId,
          name: updateName,
          // phone not provided
        );

        // Assert
        final captured = verify(mockUpdateUserProfileUseCase(captureAny)).captured;
        final params = captured.first as UpdateUserProfileParams;
        expect(params.updateData.containsKey('name'), true);
        expect(params.updateData.containsKey('phone'), false);
        expect(params.updateData['name'], updateName);
      });
    });

    group('error message mapping', () {
      test('should map ServerFailure correctly', () async {
        // Arrange
        const failure = ServerFailure('Server error');
        when(mockGetUserProfileUseCase(testUserId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        await viewModel.loadUserProfile(testUserId);

        // Assert
        expect(viewModel.errorMessage, 'Server error occurred');
      });

      test('should map CacheFailure correctly', () async {
        // Arrange
        const failure = CacheFailure('Cache error');
        when(mockGetUserProfileUseCase(testUserId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        await viewModel.loadUserProfile(testUserId);

        // Assert
        expect(viewModel.errorMessage, 'Local data error occurred');
      });

      test('should map NetworkFailure correctly', () async {
        // Arrange
        const failure = NetworkFailure('Network error');
        when(mockGetUserProfileUseCase(testUserId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        await viewModel.loadUserProfile(testUserId);

        // Assert
        expect(viewModel.errorMessage, 'Network error occurred');
      });
    });
  });
}