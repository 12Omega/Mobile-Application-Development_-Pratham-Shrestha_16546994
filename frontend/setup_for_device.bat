@echo off
echo ========================================
echo ParkEase App Setup for Redmi Note 9 Pro Max
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building for Android...
flutter build apk --debug

echo.
echo Step 4: Installing on device...
flutter install

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Your app should now be installed on your Redmi Note 9 Pro Max
echo You can also run: flutter run
echo.
pause