import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  bool _hasPermission = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  LocationService() {
    _checkPermission();
  }

  // Check if location permission is granted
  Future<void> _checkPermission() async {
    _isLoading = true;
    notifyListeners();

    final status = await Permission.location.status;
    _hasPermission = status.isGranted;

    if (_hasPermission) {
      await getCurrentPosition();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Request location permission
  Future<bool> requestPermission() async {
    _isLoading = true;
    notifyListeners();

    final status = await Permission.location.request();
    _hasPermission = status.isGranted;

    if (_hasPermission) {
      await getCurrentPosition();
    }

    _isLoading = false;
    notifyListeners();

    return _hasPermission;
  }

  // Get current position with faster settings
  Future<Position?> getCurrentPosition() async {
    // Return cached position if available and recent (within 5 minutes)
    if (_currentPosition != null) {
      final now = DateTime.now();
      final positionTime = DateTime.fromMillisecondsSinceEpoch(_currentPosition!.timestamp.millisecondsSinceEpoch);
      if (now.difference(positionTime).inMinutes < 5) {
        return _currentPosition;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Quick permission check first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoading = false;
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      _hasPermission = true;

      // Use faster location settings for quicker response
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Changed from high to medium for speed
        timeLimit: const Duration(seconds: 5), // Reduced from 10 to 5 seconds
      );

      // Get address from coordinates in background (non-blocking)
      if (_currentPosition != null) {
        getAddressFromLatLng(_currentPosition!).catchError((e) {
          debugPrint('Error getting address: $e');
        });
      }

      _isLoading = false;
      notifyListeners();

      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get address from coordinates
  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress =
            '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      } else {
        _currentAddress = 'Address not found';
      }
    } catch (e) {
      _currentAddress = 'Failed to get address';
    }

    notifyListeners();
  }

  // Get coordinates from address
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
    }

    return null;
  }

  // Calculate distance between two coordinates in meters
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Start location tracking
  void startLocationTracking() {
    if (!_hasPermission) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentPosition = position;
      getAddressFromLatLng(position);
    });
  }

  // Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Get formatted address
  String getFormattedAddress() {
    return _currentAddress ?? 'Unknown location';
  }

  // Get current LatLng
  LatLng? getCurrentLatLng() {
    if (_currentPosition == null) return null;
    return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
