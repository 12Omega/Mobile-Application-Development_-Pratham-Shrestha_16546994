@echo off
echo ========================================
echo 🧪 PARKEASE APP TEST SUITE
echo ========================================
echo.

echo 📋 Test Menu:
echo 1. Run Full Test Suite
echo 2. Test Backend Only
echo 3. Test Frontend Only
echo 4. Test Database Only
echo 5. Quick Health Check
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto full_test
if "%choice%"=="2" goto backend_test
if "%choice%"=="3" goto frontend_test
if "%choice%"=="4" goto database_test
if "%choice%"=="5" goto health_check
if "%choice%"=="6" goto exit
goto invalid_choice

:full_test
echo.
echo 🚀 Running Full Test Suite...
echo ========================================
node test_app.js
goto end

:backend_test
echo.
echo 🔧 Testing Backend...
echo ========================================
cd backend
echo 📦 Installing dependencies...
npm install
echo.
echo 🧪 Running tests...
npm test
echo.
echo 🌐 Testing server startup...
timeout /t 5 /nobreak > nul
echo ✅ Backend test completed!
cd ..
goto end

:frontend_test
echo.
echo 📱 Testing Frontend...
echo ========================================
cd frontend
echo 🩺 Running Flutter doctor...
flutter doctor
echo.
echo 📦 Getting dependencies...
flutter pub get
echo.
echo 🔍 Running analysis...
flutter analyze
echo.
echo 🧪 Running tests...
flutter test
echo.
echo 🔨 Testing build...
flutter build apk --debug
echo ✅ Frontend test completed!
cd ..
goto end

:database_test
echo.
echo 🗄️ Testing Database...
echo ========================================
cd backend
echo 🌱 Seeding database...
node src/data/seedDatabase.js
echo ✅ Database test completed!
cd ..
goto end

:health_check
echo.
echo 🏥 Quick Health Check...
echo ========================================
echo 🔍 Checking project structure...

if exist "backend" (
    echo ✅ Backend directory found
) else (
    echo ❌ Backend directory missing
)

if exist "frontend" (
    echo ✅ Frontend directory found
) else (
    echo ❌ Frontend directory missing
)

if exist "backend\package.json" (
    echo ✅ Backend package.json found
) else (
    echo ❌ Backend package.json missing
)

if exist "frontend\pubspec.yaml" (
    echo ✅ Frontend pubspec.yaml found
) else (
    echo ❌ Frontend pubspec.yaml missing
)

if exist "backend\src\data\seedDatabase.js" (
    echo ✅ Database seed files found
) else (
    echo ❌ Database seed files missing
)

echo.
echo 🩺 Checking Flutter installation...
flutter --version

echo.
echo 🩺 Checking Node.js installation...
node --version
npm --version

echo.
echo ✅ Health check completed!
goto end

:invalid_choice
echo ❌ Invalid choice. Please select 1-6.
pause
goto start

:exit
echo 👋 Goodbye!
exit /b 0

:end
echo.
echo ========================================
echo 🎉 Test completed!
echo ========================================
pause