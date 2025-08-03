@echo off
REM Generate mock files for Clean Architecture tests
echo Generating mock files for Clean Architecture tests...

REM Generate mocks for profile feature tests
echo Generating mocks for profile feature...

REM Generate mocks using build_runner
flutter packages pub run build_runner build --delete-conflicting-outputs

echo Mock generation completed!
echo.
echo Generated mock files:
echo - test/features/profile/domain/usecases/get_user_profile_usecase_test.mocks.dart
echo - test/features/profile/data/repositories/profile_repository_impl_test.mocks.dart
echo - test/features/profile/presentation/viewmodels/profile_viewmodel_test.mocks.dart
echo.
echo You can now run the tests with:
echo flutter test

pause