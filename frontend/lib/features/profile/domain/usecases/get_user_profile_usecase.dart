import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, String> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}