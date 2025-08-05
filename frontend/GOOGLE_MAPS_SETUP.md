# 🗺️ Google Maps Setup Guide

This guide will help you set up Google Maps integration for the ParkEase Flutter app.

## 📋 Prerequisites

- Google Cloud Platform account
- Credit card for billing (required even for free tier)
- Flutter project with Google Maps dependency

## 🔧 Step 1: Google Cloud Console Setup

### 1. Create/Select Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Note your project ID

### 2. Enable Required APIs
Enable these APIs in the [API Library](https://console.cloud.google.com/apis/library):
- **Maps SDK for Android**
- **Maps SDK for iOS** 
- **Places API**
- **Geocoding API**
- **Geolocation API**

### 3. Create API Key
1. Go to [Credentials](https://console.cloud.google.com/apis/credentials)
2. Click **+ CREATE CREDENTIALS** → **API key**
3. Copy the generated API key
4. Click **RESTRICT KEY** for security

### 4. Restrict API Key (Recommended)
**Application restrictions:**
- Select **Android apps** and **iOS apps**
- Add your app's package name: `com.example.parkease`
- Add SHA-1 certificate fingerprint (for Android)

**API restrictions:**
- Select **Restrict key**
- Choose the APIs you enabled above

## 🤖 Step 2: Android Configuration

### 1. Add API Key to AndroidManifest.xml
Edit `frontend/android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        android:label="parkease"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Add Google Maps API Key -->
        <meta-data android:name="com.google.android.geo.API_KEY"
                   android:value="YOUR_API_KEY_HERE"/>
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 2. Get SHA-1 Certificate Fingerprint
```bash
# For debug certificate
cd frontend/android
./gradlew signingReport

# Look for SHA1 fingerprint in the output
# Add this to your API key restrictions in Google Cloud Console
```

## 🍎 Step 3: iOS Configuration

### 1. Add API Key to AppDelegate
Edit `frontend/ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 2. Update Info.plist
Edit `frontend/ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Add location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to find nearby parking spots.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs location access to find nearby parking spots.</string>
    
    <!-- Existing keys... -->
</dict>
```

## 🔧 Step 4: Flutter Configuration

### 1. Verify Dependencies
Check `frontend/pubspec.yaml` has:

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

### 2. Test Implementation
Create a test widget to verify maps work:

```dart
// frontend/lib/test_maps.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestMapsScreen extends StatefulWidget {
  @override
  _TestMapsScreenState createState() => _TestMapsScreenState();
}

class _TestMapsScreenState extends State<TestMapsScreen> {
  GoogleMapController? mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060), // New York
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Maps')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
```

## 🧪 Step 5: Testing

### 1. Run the App
```bash
cd frontend
flutter run
```

### 2. Check for Issues
Common problems and solutions:

**Maps not loading:**
- Verify API key is correct
- Check API restrictions
- Ensure billing is enabled
- Check internet connection

**Location not working:**
- Grant location permissions
- Test on physical device (not emulator)
- Check location services are enabled

**Build errors:**
- Run `flutter clean && flutter pub get`
- Check Android/iOS configuration
- Verify dependencies are compatible

### 3. Test Checklist
- [ ] Map loads correctly
- [ ] Current location shows
- [ ] Can zoom and pan
- [ ] Markers display
- [ ] Location permission granted
- [ ] Works on both debug and release builds

## 🔒 Security Best Practices

### 1. API Key Security
- **Never commit API keys to version control**
- Use environment variables or secure storage
- Restrict API key usage
- Monitor API usage regularly

### 2. Production Setup
For production, consider:
- Separate API keys for debug/release
- More restrictive API key settings
- Usage quotas and alerts
- Regular security audits

## 💰 Billing Information

### Free Tier Limits
- **Maps SDK**: 28,000 loads per month
- **Places API**: 17,000 requests per month
- **Geocoding**: 40,000 requests per month

### Cost Optimization
- Cache map data when possible
- Use appropriate zoom levels
- Implement request throttling
- Monitor usage in Google Cloud Console

## 🆘 Troubleshooting

### Common Error Messages

**"Google Maps API key not found"**
- Check AndroidManifest.xml configuration
- Verify API key is correct
- Ensure no extra spaces in key

**"This API project is not authorized"**
- Check API key restrictions
- Verify package name matches
- Add SHA-1 fingerprint

**"Billing not enabled"**
- Enable billing in Google Cloud Console
- Add valid payment method
- Wait a few minutes for activation

**"Maps SDK not enabled"**
- Enable Maps SDK in API Library
- Wait a few minutes for activation
- Check project selection

### Debug Commands
```bash
# Check Flutter configuration
flutter doctor -v

# Check Android configuration
cd frontend/android && ./gradlew signingReport

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

## 📞 Support Resources

- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Flutter Location Plugin](https://pub.dev/packages/geolocator)
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)

## ✅ Success Checklist

Your Google Maps setup is complete when:
- [ ] API key created and restricted
- [ ] Required APIs enabled
- [ ] Android configuration complete
- [ ] iOS configuration complete
- [ ] App builds without errors
- [ ] Maps load correctly
- [ ] Location services work
- [ ] Markers display properly

**Happy Mapping! 🗺️**