import 'package:flutter/material.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/services/location_service.dart';
import 'package:parkease/core/services/parking_service.dart';

class ParkingViewModel extends ChangeNotifier {
  final ParkingService _parkingService;
  final LocationService _locationService;

  List<ParkingLot> _nearbyParkingLots = [];
  ParkingLot? _selectedParkingLot;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _availabilityData;
  String? _reservedSpotNumber;
  DateTime? _reservationExpiry;

  ParkingViewModel(
    this._parkingService,
    this._locationService,
  );

  List<ParkingLot> get nearbyParkingLots => _nearbyParkingLots;
  ParkingLot? get selectedParkingLot => _selectedParkingLot;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get availabilityData => _availabilityData;
  String? get reservedSpotNumber => _reservedSpotNumber;
  DateTime? get reservationExpiry => _reservationExpiry;

  // Get nearby parking lots
  Future<void> getNearbyParkingLots() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();

      if (position == null) {
        _errorMessage = 'Unable to get current location';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get nearby parking lots
      final result = await _parkingService.getNearbyParkingLots(
        longitude: position.longitude,
        latitude: position.latitude,
        radius: 5000, // 5km radius
      );

      if (result['success']) {
        _nearbyParkingLots = result['parkingLots'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to get nearby parking lots';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get parking lot details
  Future<void> getParkingLotDetails(String parkingLotId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _parkingService.getParkingLotDetails(parkingLotId);

      if (result['success']) {
        _selectedParkingLot = result['parkingLot'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to get parking lot details';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get parking lot availability
  Future<void> getParkingLotAvailability(String parkingLotId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _parkingService.getParkingLotAvailability(parkingLotId);

      if (result['success']) {
        _availabilityData = result['data'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to get parking lot availability';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Reserve parking spot
  Future<bool> reserveParkingSpot(
      String parkingLotId, String spotNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _parkingService.reserveParkingSpot(
        parkingLotId: parkingLotId,
        spotNumber: spotNumber,
        duration: 120, // 2 hours in minutes
      );

      if (result['success']) {
        _reservedSpotNumber = result['data']['spotNumber'];
        _reservationExpiry = DateTime.parse(result['data']['reservedUntil']);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to reserve parking spot';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search parking lots by location
  Future<void> searchParkingLots(String location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get coordinates from address
      final coordinates =
          await _locationService.getCoordinatesFromAddress(location);

      if (coordinates == null) {
        _errorMessage = 'Location not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get nearby parking lots
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

  // Clear selected parking lot
  void clearSelectedParkingLot() {
    _selectedParkingLot = null;
    _availabilityData = null;
    notifyListeners();
  }

  // Clear reservation
  void clearReservation() {
    _reservedSpotNumber = null;
    _reservationExpiry = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Toggle favorite status for a parking lot
  Future<bool> toggleFavorite(String parkingLotId) async {
    try {
      final result = await _parkingService.toggleFavorite(parkingLotId);

      if (result['success']) {
        final isFavorite = result['isFavorite'];

        // Update the selected parking lot if it matches
        if (_selectedParkingLot != null &&
            _selectedParkingLot!.id == parkingLotId) {
          _selectedParkingLot = _selectedParkingLot!..isFavorite = isFavorite;
        }

        // Update in the nearby parking lots list if it exists there
        final index =
            _nearbyParkingLots.indexWhere((lot) => lot.id == parkingLotId);
        if (index != -1) {
          _nearbyParkingLots[index] = _nearbyParkingLots[index]
            ..isFavorite = isFavorite;
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update favorite status';
      notifyListeners();
      return false;
    }
  }
}
