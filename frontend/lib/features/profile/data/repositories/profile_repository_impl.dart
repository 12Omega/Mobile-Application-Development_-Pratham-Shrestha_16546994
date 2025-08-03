import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getUserProfile(userId);
        await localDataSource.cacheUserProfile(remoteProfile);
        return Right(remoteProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localProfile = await localDataSource.getCachedUserProfile(userId);
        return Right(localProfile.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updateUserProfile(userId, updateData);
        await localDataSource.cacheUserProfile(updatedProfile);
        return Right(updatedProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUserProfile(userId);
        await localDataSource.clearCachedUserProfile(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.uploadProfileImage(userId, imagePath);
        await localDataSource.cacheUserProfile(updatedProfile);
        return Right(updatedProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}