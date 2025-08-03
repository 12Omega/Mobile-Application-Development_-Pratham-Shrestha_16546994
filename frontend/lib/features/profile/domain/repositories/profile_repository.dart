import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  );
  Future<Either<Failure, void>> deleteUserProfile(String userId);
  Future<Either<Failure, UserProfile>> uploadProfileImage(
    String userId,
    String imagePath,
  );
}