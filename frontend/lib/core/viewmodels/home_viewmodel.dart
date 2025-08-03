import 'package:flutter/material.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/services/auth_service.dart';
import 'package:parkease/core/services/booking_service.dart';
import 'package:parkease/core/services/location_service.dart';
import 'package:parkease/core/services/parking_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ParkingService _parkingService;
  final BookingService _bookingService;
  final LocationService _locationService;

  User? _user;
  List<ParkingLot> _nearbyParkingLots = [];
  List<Booking> _activeBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  HomeViewModel(
    this._authService,
    this._parkingService,
    this._bookingService,
    this._locationService,
  ) {
    _initialize();
  }

  User? get user => _user;
  List<ParkingLot> get nearbyParkingLots => _nearbyParkingLots;
  List<Booking> get activeBookings => _activeBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize view model
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user data
      final userData = await _authService.getStoredUser();
      if (userData != null) {
        _user = userData;
      }

      // Request location permission if needed
      if (!_locationService.hasPermission) {
        await _locationService.requestPermission();
      }

      // Load data in parallel
      await Future.wait([
        _loadNearbyParkingLots(),
        _loadActiveBookings(),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to initialize home screen';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load nearby parking lots
  Future<void> _loadNearbyParkingLots() async {
    try {
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        final result = await _parkingService.getNearbyParkingLots(
          longitude: position.longitude,
          latitude: position.latitude,
          radius: 5000, // 5km radius
        );

        if (result['success']) {
          _nearbyParkingLots = result['parkingLots'];
        }
      }
    } catch (e) {
      // Silent failure
    }
  }

  // Load active bookings
  Future<void> _loadActiveBookings() async {
    try {
      final result = await _bookingService.getUserBookings(
        status: 'active',
        limit: 5,
      );

      if (result['success']) {
        _activeBookings = result['bookings'];
      }
    } catch (e) {
      // Silent failure
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Refresh user data
      final userResult = await _authService.getCurrentUser();
      if (userResult['success']) {
        _user = userResult['user'];
      }

      // Load data in parallel
      await Future.wait([
        _loadNearbyParkingLots(),
        _loadActiveBookings(),
      ]);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh data';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Search parking lots
  Future<void> searchParkingLots(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get coordinates from address
      final coordinates =
          await _locationService.getCoordinatesFromAddress(query);

      if (coordinates != null) {
        final result = await _parkingService.getNearbyParkingLots(
          longitude: coordinates.longitude,
          latitude: coordinates.latitude,
          radius: 5000, // 5km radius
        );

        if (result['success']) {
          _nearbyParkingLots = result['parkingLots'];
          _errorMessage = null;
        } else {
          _errorMessage = result['message'];
        }
      } else {
        _errorMessage = 'Location not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to search parking lots';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter parking lots by amenities
  void filterParkingLotsByAmenities(List<String> amenities) {
    if (amenities.isEmpty) return;

    _nearbyParkingLots = _nearbyParkingLots.where((parkingLot) {
      return amenities
          .every((amenity) => parkingLot.amenities.contains(amenity));
    }).toList();

    notifyListeners();
  }

  // Sort parking lots by distance
  void sortParkingLotsByDistance() {
    final currentLocation = _locationService.getCurrentLatLng();

    if (currentLocation == null) return;

    _nearbyParkingLots.sort((a, b) {
      final distanceA = _locationService.calculateDistance(
        currentLocation,
        a.latLng,
      );

      final distanceB = _locationService.calculateDistance(
        currentLocation,
        b.latLng,
      );

      return distanceA.compareTo(distanceB);
    });

    notifyListeners();
  }

  // Sort parking lots by price
  void sortParkingLotsByPrice() {
    _nearbyParkingLots.sort((a, b) {
      return a.pricing.hourlyRate.compareTo(b.pricing.hourlyRate);
    });

    notifyListeners();
  }

  // Sort parking lots by availability
  void sortParkingLotsByAvailability() {
    _nearbyParkingLots.sort((a, b) {
      return b.availableSpots.compareTo(a.availableSpots);
    });

    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
