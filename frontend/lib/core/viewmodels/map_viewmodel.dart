import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/services/location_service.dart';
import 'package:parkease/core/services/parking_service.dart';
import 'package:parkease/core/utils/app_config.dart';

class MapViewModel extends ChangeNotifier {
  final LocationService _locationService;
  final ParkingService _parkingService;

  GoogleMapController? _mapController;
  CameraPosition? _initialCameraPosition;
  Set<Marker> _markers = {};
  List<ParkingLot> _parkingLots = [];
  ParkingLot? _selectedParkingLot;
  bool _isLoading = false;
  String? _errorMessage;

  MapViewModel(
    this._locationService,
    this._parkingService,
  ) {
    _initialize();
  }

  GoogleMapController? get mapController => _mapController;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;
  Set<Marker> get markers => _markers;
  List<ParkingLot> get parkingLots => _parkingLots;
  ParkingLot? get selectedParkingLot => _selectedParkingLot;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize view model
  Future<void> _initialize() async {
    _isLoading = true;
    
    // Set default location immediately to show map faster
    _initialCameraPosition = const CameraPosition(
      target: LatLng(27.7172, 85.3240), // Kathmandu, Nepal coordinates
      zoom: AppConfig.defaultMapZoom,
    );
    
    // Load mock data immediately for faster display (non-blocking)
    _loadMockParkingLotsSync();
    
    _isLoading = false;
    notifyListeners();

    // Try to get user location in background and update if available
    _updateUserLocationAsync();
  }

  // Update user location in background (async, non-blocking)
  void _updateUserLocationAsync() {
    _updateUserLocation().catchError((e) {
      debugPrint('Could not get user location: $e');
    });
  }

  // Update user location in background
  Future<void> _updateUserLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        // Update camera position to user location
        final userLatLng = LatLng(position.latitude, position.longitude);
        
        // Add/update user marker
        _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: userLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );

        // Move camera to user location if map controller is available
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(userLatLng, AppConfig.defaultMapZoom),
          );
        } else {
          // Update initial camera position for when map loads
          _initialCameraPosition = CameraPosition(
            target: userLatLng,
            zoom: AppConfig.defaultMapZoom,
          );
        }

        // Load parking lots around user location
        await _loadNearbyParkingLots(position.latitude, position.longitude);
        
        notifyListeners();
      }
    } catch (e) {
      // Keep using default location and mock data
      debugPrint('Could not get user location: $e');
    }
  }

  // Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  // Load nearby parking lots
  Future<void> _loadNearbyParkingLots(double latitude, double longitude) async {
    try {
      final result = await _parkingService.getNearbyParkingLots(
        longitude: longitude,
        latitude: latitude,
        radius: AppConfig.defaultSearchRadius,
      );

      if (result['success']) {
        _parkingLots = result['parkingLots'];
        _addParkingLotMarkers();
      } else {
        // Fallback to mock data if API fails
        await _loadMockParkingLots();
      }
    } catch (e) {
      // Fallback to mock data on error
      await _loadMockParkingLots();
    }
  }

  // Load mock parking lots synchronously for faster initial display
  void _loadMockParkingLotsSync() {
    // Create mock parking lots around the current location or default location
    final baseLatLng = _initialCameraPosition?.target ?? const LatLng(27.7172, 85.3240);
    
    _parkingLots = [
      ParkingLot(
        id: 'mock_1',
        name: 'Thamel Parking Plaza',
        address: Address(
          street: 'Thamel Marg',
          city: 'Kathmandu',
          state: 'Bagmati',
          zipCode: '44600',
          country: 'Nepal',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLatLng.longitude + 0.001, baseLatLng.latitude + 0.001],
        ),
        totalSpots: 50,
        availableSpots: 23,
        spots: _generateParkingSpots(50, 23, ['regular', 'disabled', 'electric']),
        pricing: Pricing(
          hourlyRate: 150.0,
          dailyRate: 1200.0,
          currency: 'NPR',
        ),
        amenities: ['covered', 'security', 'ev_charging'],
        operatingHours: OperatingHours(
          open: '06:00',
          close: '22:00',
          is24Hours: false,
        ),
        contactInfo: ContactInfo(
          phone: '+977-1-4441234',
          email: 'info@thamelparking.com.np',
        ),
        isActive: true,
        managedBy: 'Thamel Parking Management',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'mock_2',
        name: 'Durbar Marg Garage',
        address: Address(
          street: 'Durbar Marg',
          city: 'Kathmandu',
          state: 'Bagmati',
          zipCode: '44600',
          country: 'Nepal',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLatLng.longitude + 0.003, baseLatLng.latitude - 0.002],
        ),
        totalSpots: 75,
        availableSpots: 12,
        spots: _generateParkingSpots(75, 12, ['regular', 'disabled', 'electric', 'compact']),
        pricing: Pricing(
          hourlyRate: 200.0,
          dailyRate: 1500.0,
          currency: 'NPR',
        ),
        amenities: ['covered', 'security', '24_7'],
        operatingHours: OperatingHours(
          open: '00:00',
          close: '23:59',
          is24Hours: true,
        ),
        contactInfo: ContactInfo(
          phone: '+977-1-4442345',
          email: 'info@durbarmarggarage.com.np',
        ),
        isActive: true,
        managedBy: 'Durbar Marg Management',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'mock_3',
        name: 'Patan Dhoka Parking',
        address: Address(
          street: 'Patan Dhoka',
          city: 'Lalitpur',
          state: 'Bagmati',
          zipCode: '44700',
          country: 'Nepal',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLatLng.longitude - 0.001, baseLatLng.latitude + 0.003],
        ),
        totalSpots: 30,
        availableSpots: 28,
        spots: _generateParkingSpots(30, 28, ['regular', 'disabled']),
        pricing: Pricing(
          hourlyRate: 100.0,
          dailyRate: 800.0,
          currency: 'NPR',
        ),
        amenities: ['outdoor'],
        operatingHours: OperatingHours(
          open: '07:00',
          close: '19:00',
          is24Hours: false,
        ),
        contactInfo: ContactInfo(
          phone: '+977-1-5551234',
          email: 'info@patanparking.com.np',
        ),
        isActive: true,
        managedBy: 'Patan Parking Services',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'mock_4',
        name: 'Civil Mall Parking',
        address: Address(
          street: 'Sundhara',
          city: 'Kathmandu',
          state: 'Bagmati',
          zipCode: '44600',
          country: 'Nepal',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLatLng.longitude - 0.002, baseLatLng.latitude - 0.001],
        ),
        totalSpots: 120,
        availableSpots: 45,
        spots: _generateParkingSpots(120, 45, ['regular', 'disabled', 'electric', 'compact', 'family']),
        pricing: Pricing(
          hourlyRate: 80.0,
          dailyRate: 600.0,
          currency: 'NPR',
        ),
        amenities: ['covered', 'security', 'ev_charging', 'car_wash', 'valet'],
        operatingHours: OperatingHours(
          open: '06:00',
          close: '23:00',
          is24Hours: false,
        ),
        contactInfo: ContactInfo(
          phone: '+977-1-4443456',
          email: 'parking@civilmall.com.np',
        ),
        isActive: true,
        managedBy: 'Civil Mall Management',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'mock_5',
        name: 'Bagmati Riverside Parking',
        address: Address(
          street: 'Bagmati Corridor',
          city: 'Kathmandu',
          state: 'Bagmati',
          zipCode: '44600',
          country: 'Nepal',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLatLng.longitude + 0.002, baseLatLng.latitude - 0.003],
        ),
        totalSpots: 90,
        availableSpots: 67,
        spots: _generateParkingSpots(90, 67, ['regular', 'disabled', 'electric']),
        pricing: Pricing(
          hourlyRate: 120.0,
          dailyRate: 900.0,
          currency: 'NPR',
        ),
        amenities: ['covered', 'security', 'ev_charging'],
        operatingHours: OperatingHours(
          open: '05:00',
          close: '24:00',
          is24Hours: false,
        ),
        contactInfo: ContactInfo(
          phone: '+977-1-4444567',
          email: 'info@bagmatiparking.com.np',
        ),
        isActive: true,
        managedBy: 'Bagmati Parking Corp',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];

    _addParkingLotMarkers();
  }

  // Generate realistic parking spots for a parking lot
  List<ParkingSpot> _generateParkingSpots(int totalSpots, int availableSpots, List<String> spotTypes) {
    final spots = <ParkingSpot>[];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Kathmandu coordinates
    const baseLatitude = 27.7172;
    const baseLongitude = 85.3240;
    
    // Calculate spots per type
    final regularSpots = (totalSpots * 0.8).round();
    final disabledSpots = (totalSpots * 0.05).round();
    final electricSpots = spotTypes.contains('electric') ? (totalSpots * 0.1).round() : 0;
    final compactSpots = spotTypes.contains('compact') ? (totalSpots * 0.15).round() : 0;
    final familySpots = spotTypes.contains('family') ? (totalSpots * 0.05).round() : 0;
    
    int spotCounter = 1;
    int occupiedCount = totalSpots - availableSpots;
    
    // Generate regular spots
    for (int i = 0; i < regularSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = occupiedCount > 0 && (spotCounter + random) % 3 == 0;
      if (isOccupied) occupiedCount--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'A'),
        type: 'regular',
        isAvailable: !isOccupied,
        isReserved: false,
        coordinates: SpotCoordinates(
          latitude: 40.7128 + (spotCounter * 0.0001),
          longitude: -74.0060 + (spotCounter * 0.0001),
        ),
      ));
      spotCounter++;
    }
    
    // Generate disabled spots
    for (int i = 0; i < disabledSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = occupiedCount > 0 && (spotCounter + random) % 4 == 0;
      if (isOccupied) occupiedCount--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'D'),
        type: 'disabled',
        isAvailable: !isOccupied,
        isReserved: false,
        coordinates: SpotCoordinates(
          latitude: 40.7128 + (spotCounter * 0.0001),
          longitude: -74.0060 + (spotCounter * 0.0001),
        ),
      ));
      spotCounter++;
    }
    
    // Generate electric spots
    for (int i = 0; i < electricSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = occupiedCount > 0 && (spotCounter + random) % 5 == 0;
      if (isOccupied) occupiedCount--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'E'),
        type: 'electric',
        isAvailable: !isOccupied,
        isReserved: false,
        coordinates: SpotCoordinates(
          latitude: 40.7128 + (spotCounter * 0.0001),
          longitude: -74.0060 + (spotCounter * 0.0001),
        ),
      ));
      spotCounter++;
    }
    
    // Generate compact spots
    for (int i = 0; i < compactSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = occupiedCount > 0 && (spotCounter + random) % 3 == 0;
      if (isOccupied) occupiedCount--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'C'),
        type: 'compact',
        isAvailable: !isOccupied,
        isReserved: false,
        coordinates: SpotCoordinates(
          latitude: 40.7128 + (spotCounter * 0.0001),
          longitude: -74.0060 + (spotCounter * 0.0001),
        ),
      ));
      spotCounter++;
    }
    
    // Generate family spots
    for (int i = 0; i < familySpots && spotCounter <= totalSpots; i++) {
      final isOccupied = occupiedCount > 0 && (spotCounter + random) % 4 == 0;
      if (isOccupied) occupiedCount--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'F'),
        type: 'family',
        isAvailable: !isOccupied,
        isReserved: false,
        coordinates: SpotCoordinates(
          latitude: 40.7128 + (spotCounter * 0.0001),
          longitude: -74.0060 + (spotCounter * 0.0001),
        ),
      ));
      spotCounter++;
    }
    
    // Fill remaining spots with regular spots
    while (spotCounter <= totalSpots) {
      final isOccupied = occupiedCount > 0;
      if (isOccupied) occupiedCount--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'A'),
        type: 'regular',
        isAvailable: !isOccupied,
        isReserved: false,
        coordinates: SpotCoordinates(
          latitude: 40.7128 + (spotCounter * 0.0001),
          longitude: -74.0060 + (spotCounter * 0.0001),
        ),
      ));
      spotCounter++;
    }
    
    return spots;
  }
  
  // Format spot number with section prefix
  String _formatSpotNumber(int number, String section) {
    if (number <= 99) {
      return '$section${number.toString().padLeft(2, '0')}';
    } else {
      return '$section${number.toString()}';
    }
  }

  // Load mock parking lots for development/testing (async version)
  Future<void> _loadMockParkingLots() async {
    _loadMockParkingLotsSync();
  }

  // Add parking lot markers to map
  void _addParkingLotMarkers() {
    for (final parkingLot in _parkingLots) {
      final marker = Marker(
        markerId: MarkerId('parking_${parkingLot.id}'),
        position: parkingLot.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: parkingLot.name,
          snippet:
              '${parkingLot.availableSpots}/${parkingLot.totalSpots} spots available',
        ),
        onTap: () => selectParkingLot(parkingLot),
      );

      _markers.add(marker);
    }

    notifyListeners();
  }

  // Select parking lot
  void selectParkingLot(ParkingLot parkingLot) {
    _selectedParkingLot = parkingLot;

    // Animate camera to selected parking lot
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        parkingLot.latLng,
        18.0, // Zoom in closer
      ),
    );

    notifyListeners();
  }

  // Clear selected parking lot
  void clearSelectedParkingLot() {
    _selectedParkingLot = null;
    notifyListeners();
  }

  // Move camera to user location
  Future<void> moveToUserLocation() async {
    final position = await _locationService.getCurrentPosition();

    if (position != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          AppConfig.defaultMapZoom,
        ),
      );
    }
  }

  // Search location
  Future<void> searchLocation(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final coordinates =
          await _locationService.getCoordinatesFromAddress(query);

      if (coordinates != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            coordinates,
            AppConfig.defaultMapZoom,
          ),
        );

        // Load nearby parking lots
        await _loadNearbyParkingLots(
            coordinates.latitude, coordinates.longitude);
      } else {
        _errorMessage = 'Location not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to search location';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh map data
  Future<void> refreshMapData() async {
    _isLoading = true;
    _errorMessage = null;
    _markers.clear();
    _parkingLots.clear();
    _selectedParkingLot = null;
    notifyListeners();

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        // Add user marker
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );

        // Load nearby parking lots
        await _loadNearbyParkingLots(position.latitude, position.longitude);
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh map data';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
