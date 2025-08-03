import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  ProfileViewModel({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  });

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await getUserProfileUseCase(userId);
    
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (profile) => _setUserProfile(profile),
    );

    _setLoading(false);
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;

    final params = UpdateUserProfileParams(
      userId: userId,
      updateData: updateData,
    );

    final result = await updateUserProfileUseCase(params);
    
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (profile) => _setUserProfile(profile),
    );

    _setLoading(false);
  }

  void _setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case CacheFailure:
        return 'Local data error occurred';
      case NetworkFailure:
        return 'Network error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}