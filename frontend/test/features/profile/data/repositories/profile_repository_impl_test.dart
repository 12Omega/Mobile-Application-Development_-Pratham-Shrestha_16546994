import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:parkease/core/error/exceptions.dart';
import 'package:parkease/core/error/failures.dart';
import 'package:parkease/core/network/network_info.dart';
import 'package:parkease/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:parkease/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:parkease/features/profile/data/models/user_profile_dto.dart';
import 'package:parkease/features/profile/data/repositories/profile_repository_impl.dart';
// Removed unused import

import 'profile_repository_impl_test.mocks.dart';

@GenerateMocks([
  ProfileRemoteDataSource,
  ProfileLocalDataSource,
  NetworkInfo,
])
void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockProfileLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockLocalDataSource = MockProfileLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const testUserId = '123';
  final testUserProfileDto = UserProfileDto(
    id: testUserId,
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1234567890',
    createdAt: '2023-01-01T00:00:00.000Z',
    updatedAt: '2023-01-01T00:00:00.000Z',
  );

  final testUserProfile = testUserProfileDto.toEntity();

  group('getUserProfile', () {
    test('should return remote data when device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfileDto);

      // Act
      final result = await repository.getUserProfile(testUserId);

      // Assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserProfile(testUserId));
      verify(mockLocalDataSource.cacheUserProfile(testUserProfileDto));
      expect(result, Right(testUserProfile));
    });

    test('should return cached data when device is offline', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfileDto);

      // Act
      final result = await repository.getUserProfile(testUserId);

      // Assert
      verify(mockNetworkInfo.isConnected);
      verify(mockLocalDataSource.getCachedUserProfile(testUserId));
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, Right(testUserProfile));
    });

    test('should return server failure when remote call fails', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserProfile(testUserId))
          .thenThrow(ServerException('Server error'));

      // Act
      final result = await repository.getUserProfile(testUserId);

      // Assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getUserProfile(testUserId));
      expect(result, const Left(ServerFailure('Server error')));
    });

    test('should return cache failure when offline and no cached data',
        () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedUserProfile(testUserId))
          .thenThrow(CacheException('No cached data'));

      // Act
      final result = await repository.getUserProfile(testUserId);

      // Assert
      verify(mockNetworkInfo.isConnected);
      verify(mockLocalDataSource.getCachedUserProfile(testUserId));
      expect(result, const Left(CacheFailure('No cached data')));
    });
  });

  group('updateUserProfile', () {
    const updateData = {'name': 'Jane Doe'};

    test('should return updated profile when device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updateUserProfile(testUserId, updateData))
          .thenAnswer((_) async => testUserProfileDto);

      // Act
      final result = await repository.updateUserProfile(testUserId, updateData);

      // Assert
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.updateUserProfile(testUserId, updateData));
      verify(mockLocalDataSource.cacheUserProfile(testUserProfileDto));
      expect(result, Right(testUserProfile));
    });

    test('should return network failure when device is offline', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.updateUserProfile(testUserId, updateData);

      // Assert
      verify(mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
      expect(result, const Left(NetworkFailure('No internet connection')));
    });
  });
}
