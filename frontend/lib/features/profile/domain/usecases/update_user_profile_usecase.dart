import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase implements UseCase<UserProfile, UpdateUserProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(params.userId, params.updateData);
  }
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final Map<String, dynamic> updateData;

  const UpdateUserProfileParams({
    required this.userId,
    required this.updateData,
  });

  @override
  List<Object> get props => [userId, updateData];
}