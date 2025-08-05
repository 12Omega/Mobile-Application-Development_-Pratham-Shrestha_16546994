@echo off
echo ========================================
echo 🚀 ParkEase Installation Script
echo ========================================
echo.

echo 📋 This script will set up ParkEase on your system
echo.

echo 🔍 Checking prerequisites...
echo.

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
) else (
    echo ✅ Node.js found
    node --version
)

REM Check Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter not found. Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
) else (
    echo ✅ Flutter found
    flutter --version | findstr "Flutter"
)

echo.
echo 📦 Installing dependencies...
echo.

REM Install root dependencies
echo 🔧 Installing root dependencies...
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install root dependencies
    pause
    exit /b 1
)

REM Install backend dependencies
echo 🔧 Installing backend dependencies...
cd backend
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install backend dependencies
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo 📝 Creating .env file...
    copy .env.example .env
    echo ⚠️  Please edit backend/.env with your configurations
)

cd ..

REM Install frontend dependencies
echo 🔧 Installing frontend dependencies...
cd frontend
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to install frontend dependencies
    pause
    exit /b 1
)

cd ..

echo.
echo 🗄️ Setting up database...
cd backend
node src/data/seedDatabase.js
if %errorlevel% neq 0 (
    echo ⚠️  Database seeding failed. Make sure MongoDB is running.
    echo 💡 You can run 'npm run seed' later to populate the database.
)

cd ..

echo.
echo 🧪 Running quick test...
node quick_test.js

echo.
echo ========================================
echo 🎉 Installation Complete!
echo ========================================
echo.
echo 📋 Next Steps:
echo 1. Edit backend/.env with your configurations
echo 2. Set up Google Maps API key (see frontend/GOOGLE_MAPS_SETUP.md)
echo 3. Start the backend: npm run start:backend
echo 4. Start the frontend: npm run start:frontend
echo.
echo 📚 Documentation:
echo - Setup Guide: SETUP.md
echo - Google Maps: frontend/GOOGLE_MAPS_SETUP.md
echo - Contributing: CONTRIBUTING.md
echo.
echo 🚀 Happy coding!
echo.
pause