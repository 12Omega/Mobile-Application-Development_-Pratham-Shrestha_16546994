@echo off
echo Running Clean Architecture Tests...
echo.

echo Testing Use Cases...
flutter test test/features/profile/domain/usecases/get_user_profile_usecase_test.dart
echo.

echo Testing Repositories...
flutter test test/features/profile/data/repositories/profile_repository_impl_test.dart
echo.

echo Testing ViewModels...
flutter test test/features/profile/presentation/viewmodels/profile_viewmodel_test.dart
echo.

echo All Clean Architecture tests completed!
pause