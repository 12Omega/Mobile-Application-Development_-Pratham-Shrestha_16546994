# Google Maps Setup Guide

The map is currently taking too long to load because it's running in development mode without a proper Google Maps API key. Here's how to fix it:

## Quick Fix (Recommended)

### Step 1: Get Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API
4. Create credentials → API Key
5. Restrict the API key to your app (optional but recommended)

### Step 2: Configure Android
Replace `DEVELOPMENT_MODE` in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### Step 3: Configure iOS
Add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 4: Update App Config
Update `frontend/lib/core/utils/app_config.dart`:

```dart
static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

## Alternative: Use List View Only

If you don't want to set up Google Maps API key right now, the app will automatically fall back to a list view of parking lots, which loads much faster.

## Performance Optimizations Applied

The following optimizations have been applied to improve map loading speed:

1. **Faster Initialization**: Map now loads with default location immediately
2. **Background Location**: User location is fetched in background without blocking UI
3. **Cached Location**: Location service now caches recent positions
4. **Reduced Accuracy**: Using medium accuracy instead of high for faster GPS lock
5. **Shorter Timeout**: Reduced location timeout from 10s to 5s
6. **List Fallback**: Automatic fallback to list view when map fails
7. **Loading States**: Better loading indicators and error handling

## Testing

After setting up the API key:
1. Hot restart the app (not just hot reload)
2. The map should load much faster
3. Location should be acquired within 5 seconds
4. Parking lots should appear as markers on the map

## Troubleshooting

- **Map still not loading**: Check API key is correct and APIs are enabled
- **Location not working**: Check location permissions in device settings
- **Slow performance**: Try clearing app data and restarting