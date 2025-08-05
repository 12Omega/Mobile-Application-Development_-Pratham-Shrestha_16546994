# 🚀 ParkEase Setup Guide

This guide will help you set up the ParkEase application from scratch after cloning from GitHub.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

### Required Software
- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **Flutter SDK** (v3.0 or higher) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Git** - [Download](https://git-scm.com/)
- **MongoDB** (local or cloud) - [Install Guide](https://docs.mongodb.com/manual/installation/)

### Development Tools (Choose one)
- **Android Studio** - [Download](https://developer.android.com/studio)
- **VS Code** with Flutter extension - [Download](https://code.visualstudio.com/)

### Device Requirements
- **Android device** (API level 21+) or **iOS device** (iOS 11+)
- **USB cable** for device connection
- **Developer options enabled** on Android device

## 🔧 Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/12Omega/Mobile-Application-Development_-Pratham-Shrestha_16546994.git
cd Mobile-Application-Development_-Pratham-Shrestha_16546994
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
copy .env.example .env
# On Linux/Mac: cp .env.example .env

# Edit .env file with your configurations
# Use any text editor to modify the .env file
```

**Edit the `.env` file:**
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/parkease
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRE=7d
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```

### 3. Frontend Setup

```bash
# Navigate to frontend directory (from project root)
cd frontend

# Get Flutter dependencies
flutter pub get

# Check Flutter installation
flutter doctor
```

**Fix any issues shown by `flutter doctor`**

### 4. Database Setup

```bash
# From backend directory
cd backend

# Seed the database with dummy data
node src/data/seedDatabase.js
```

### 5. Google Maps API Setup

1. **Get Google Maps API Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing
   - Enable Maps SDK for Android/iOS
   - Create API key

2. **Configure Android:**
   ```xml
   <!-- Edit: frontend/android/app/src/main/AndroidManifest.xml -->
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_API_KEY_HERE"/>
   ```

3. **Configure iOS:**
   ```swift
   // Edit: frontend/ios/Runner/AppDelegate.swift
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```

### 6. Run the Application

**Start Backend Server:**
```bash
cd backend
npm run dev
```

**Start Frontend App:**
```bash
cd frontend
flutter run
```

## 🧪 Verify Installation

Run the test script to verify everything is working:

```bash
# From project root
node quick_test.js
```

You should see all tests passing ✅

## 📱 Device Setup (Android)

### Enable Developer Options:
1. Go to **Settings** → **About phone**
2. Tap **Build number** 7 times
3. Go to **Settings** → **Developer options**
4. Enable **USB debugging**
5. Enable **Install via USB**

### For Redmi/MIUI devices:
1. Disable **MIUI optimization** in Developer options
2. Restart device
3. Allow USB debugging when prompted

### Connect Device:
```bash
# Check if device is connected
flutter devices

# Should show your device in the list
```

## 🔧 Troubleshooting

### Common Issues:

**1. Flutter Doctor Issues:**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Update Flutter
flutter upgrade
```

**2. Node.js Issues:**
```bash
# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

**3. MongoDB Connection Issues:**
- Ensure MongoDB is running locally
- Or use MongoDB Atlas (cloud) and update MONGODB_URI
- Check firewall settings

**4. Google Maps Not Loading:**
- Verify API key is correct
- Enable required APIs in Google Cloud Console
- Check billing is enabled for the project

**5. Device Not Detected:**
```bash
# Restart ADB
adb kill-server
adb start-server

# Check USB debugging is enabled
adb devices
```

### Quick Fixes:

**Reset Everything:**
```bash
# Backend
cd backend
rm -rf node_modules package-lock.json
npm install

# Frontend
cd frontend
flutter clean
flutter pub get

# Restart devices/emulators
```

## 📊 Test Data

The app comes with pre-populated test data:
- **7 users** (including 1 admin)
- **8 parking lots** across different cities
- **50+ bookings** with various statuses
- **1000+ parking spots**

**Test Login Credentials:**
- Email: `john.smith@email.com`
- Password: `password123`

## 🚀 Development Workflow

1. **Start Backend:** `cd backend && npm run dev`
2. **Start Frontend:** `cd frontend && flutter run`
3. **Run Tests:** `node quick_test.js`
4. **View Database:** Use MongoDB Compass with connection string from `.env`

## 📞 Support

If you encounter issues:

1. **Check Prerequisites:** Ensure all required software is installed
2. **Run Test Script:** `node quick_test.js` to identify issues
3. **Check Logs:** Look at console output for error messages
4. **Restart Services:** Stop and restart backend/frontend
5. **Clean Build:** Run clean commands and reinstall dependencies

## 🎯 Success Indicators

You'll know setup is successful when:
- ✅ Test script shows all tests passing
- ✅ Backend server starts without errors
- ✅ Flutter app launches on device/emulator
- ✅ Maps load correctly with parking locations
- ✅ You can login with test credentials
- ✅ Database shows populated data

**Happy Coding! 🚀**