import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/services/api_service.dart';

class ParkingService {
  final ApiService _apiService;

  ParkingService(this._apiService);

  // Get nearby parking lots
  Future<Map<String, dynamic>> getNearbyParkingLots({
    required double longitude,
    required double latitude,
    double radius = 5000,
  }) async {
    // Return mock data for development - reduced delay for faster loading
    await Future.delayed(const Duration(milliseconds: 100)); // Faster loading
    
    final mockParkingLots = _generateMockParkingLots(latitude, longitude);
    
    return {
      'success': true,
      'parkingLots': mockParkingLots,
      'count': mockParkingLots.length,
    };
  }

  // Generate mock parking lots around a location
  List<ParkingLot> _generateMockParkingLots(double baseLat, double baseLng) {
    return [
      ParkingLot(
        id: 'parking_1',
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
          coordinates: [baseLng + 0.001, baseLat + 0.001],
        ),
        totalSpots: 50,
        availableSpots: 23,
        spots: _generateMockSpots(50, 23),
        pricing: Pricing(
          hourlyRate: 150.0,
          dailyRate: 1200.0,
          currency: 'NPR',
        ),
        amenities: ['covered', 'security', 'ev_charging', 'handicap_accessible'],
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
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'parking_2',
        name: 'City Center Garage',
        address: Address(
          street: '456 Broadway',
          city: 'Midtown',
          state: 'NY',
          zipCode: '10002',
          country: 'USA',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLng + 0.003, baseLat - 0.002],
        ),
        totalSpots: 75,
        availableSpots: 12,
        spots: _generateMockSpots(75, 12),
        pricing: Pricing(
          hourlyRate: 12.00,
          dailyRate: 85.00,
          currency: 'USD',
        ),
        amenities: ['covered', 'security', '24_7', 'valet', 'car_wash'],
        operatingHours: OperatingHours(
          open: '00:00',
          close: '23:59',
          is24Hours: true,
        ),
        contactInfo: ContactInfo(
          phone: '+1-555-0456',
          email: 'info@citycentergarage.com',
        ),
        isActive: true,
        managedBy: 'City Center Management',
        createdAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'parking_3',
        name: 'Quick Park Express',
        address: Address(
          street: '789 Park Avenue',
          city: 'Uptown',
          state: 'NY',
          zipCode: '10003',
          country: 'USA',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLng - 0.001, baseLat + 0.003],
        ),
        totalSpots: 30,
        availableSpots: 28,
        spots: _generateMockSpots(30, 28),
        pricing: Pricing(
          hourlyRate: 6.00,
          dailyRate: 40.00,
          currency: 'USD',
        ),
        amenities: ['outdoor', 'handicap_accessible'],
        operatingHours: OperatingHours(
          open: '07:00',
          close: '19:00',
          is24Hours: false,
        ),
        contactInfo: ContactInfo(
          phone: '+1-555-0789',
          email: 'info@quickpark.com',
        ),
        isActive: true,
        managedBy: 'Quick Park LLC',
        createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'parking_4',
        name: 'Premium Parking Tower',
        address: Address(
          street: '321 Fifth Avenue',
          city: 'Manhattan',
          state: 'NY',
          zipCode: '10004',
          country: 'USA',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLng - 0.002, baseLat - 0.001],
        ),
        totalSpots: 120,
        availableSpots: 45,
        spots: _generateMockSpots(120, 45),
        pricing: Pricing(
          hourlyRate: 15.00,
          dailyRate: 120.00,
          currency: 'USD',
        ),
        amenities: ['covered', 'security', 'ev_charging', 'valet', 'car_wash', '24_7'],
        operatingHours: OperatingHours(
          open: '00:00',
          close: '23:59',
          is24Hours: true,
        ),
        contactInfo: ContactInfo(
          phone: '+1-555-0999',
          email: 'premium@parkingtower.com',
        ),
        isActive: true,
        managedBy: 'Premium Parking Corp',
        createdAt: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ParkingLot(
        id: 'parking_5',
        name: 'Budget Parking Lot',
        address: Address(
          street: '654 Second Street',
          city: 'Brooklyn',
          state: 'NY',
          zipCode: '10005',
          country: 'USA',
        ),
        location: Location(
          type: 'Point',
          coordinates: [baseLng + 0.002, baseLat - 0.003],
        ),
        totalSpots: 40,
        availableSpots: 35,
        spots: _generateMockSpots(40, 35),
        pricing: Pricing(
          hourlyRate: 4.00,
          dailyRate: 25.00,
          currency: 'USD',
        ),
        amenities: ['outdoor', 'handicap_accessible'],
        operatingHours: OperatingHours(
          open: '08:00',
          close: '18:00',
          is24Hours: false,
        ),
        contactInfo: ContactInfo(
          phone: '+1-555-0111',
          email: 'info@budgetparking.com',
        ),
        isActive: true,
        managedBy: 'Budget Parking Solutions',
        createdAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  // Generate mock parking spots
  List<ParkingSpot> _generateMockSpots(int totalSpots, int availableSpots) {
    final spots = <ParkingSpot>[];
    final occupiedSpots = totalSpots - availableSpots;
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Calculate spots per type
    final regularSpots = (totalSpots * 0.75).round();
    final compactSpots = (totalSpots * 0.15).round();
    final handicapSpots = (totalSpots * 0.05).round();
    final electricSpots = (totalSpots * 0.05).round();
    
    int spotCounter = 1;
    int remainingOccupied = occupiedSpots;
    
    // Generate regular spots
    for (int i = 0; i < regularSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = remainingOccupied > 0 && (spotCounter + random) % 3 == 0;
      if (isOccupied) remainingOccupied--;
      
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
    
    // Generate compact spots
    for (int i = 0; i < compactSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = remainingOccupied > 0 && (spotCounter + random) % 4 == 0;
      if (isOccupied) remainingOccupied--;
      
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
    
    // Generate handicap spots
    for (int i = 0; i < handicapSpots && spotCounter <= totalSpots; i++) {
      final isOccupied = remainingOccupied > 0 && (spotCounter + random) % 5 == 0;
      if (isOccupied) remainingOccupied--;
      
      spots.add(ParkingSpot(
        spotNumber: _formatSpotNumber(spotCounter, 'H'),
        type: 'handicap',
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
      final isOccupied = remainingOccupied > 0 && (spotCounter + random) % 6 == 0;
      if (isOccupied) remainingOccupied--;
      
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
    
    // Fill remaining spots with regular spots
    while (spotCounter <= totalSpots) {
      final isOccupied = remainingOccupied > 0;
      if (isOccupied) remainingOccupied--;
      
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

  // Get parking lot details
  Future<Map<String, dynamic>> getParkingLotDetails(String parkingLotId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Faster loading
    
    // Find the parking lot from mock data
    final mockParkingLots = _generateMockParkingLots(40.7128, -74.0060);
    final parkingLot = mockParkingLots.firstWhere(
      (lot) => lot.id == parkingLotId,
      orElse: () => mockParkingLots.first,
    );

    return {
      'success': true,
      'parkingLot': parkingLot,
    };
  }

  // Get parking lot availability
  Future<Map<String, dynamic>> getParkingLotAvailability(
      String parkingLotId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Faster loading
    
    // Return mock availability data for development
    final mockParkingLots = _generateMockParkingLots(40.7128, -74.0060);
    final parkingLot = mockParkingLots.firstWhere(
      (lot) => lot.id == parkingLotId,
      orElse: () => mockParkingLots.first,
    );

    // Generate spot type summary
    final spotsByType = <String, Map<String, int>>{};
    
    for (final spot in parkingLot.spots) {
      if (!spotsByType.containsKey(spot.type)) {
        spotsByType[spot.type] = {'total': 0, 'available': 0};
      }
      spotsByType[spot.type]!['total'] = spotsByType[spot.type]!['total']! + 1;
      if (spot.isAvailable) {
        spotsByType[spot.type]!['available'] = spotsByType[spot.type]!['available']! + 1;
      }
    }

    return {
      'success': true,
      'data': {
        'parkingLotId': parkingLotId,
        'totalSpots': parkingLot.totalSpots,
        'availableSpots': parkingLot.availableSpots,
        'occupiedSpots': parkingLot.totalSpots - parkingLot.availableSpots,
        'spotsByType': spotsByType,
        'lastUpdated': DateTime.now().toIso8601String(),
        'realTimeData': true,
      },
    };
  }

  // Reserve parking spot
  Future<Map<String, dynamic>> reserveParkingSpot({
    required String parkingLotId,
    required String spotNumber,
    required int duration,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network delay
    
    // Return mock reservation data for development
    final reservationExpiry = DateTime.now().add(Duration(minutes: duration));
    
    return {
      'success': true,
      'data': {
        'reservationId': 'res_${DateTime.now().millisecondsSinceEpoch}',
        'parkingLotId': parkingLotId,
        'spotNumber': spotNumber,
        'duration': duration,
        'reservedAt': DateTime.now().toIso8601String(),
        'reservedUntil': reservationExpiry.toIso8601String(),
        'status': 'confirmed',
      },
    };
  }

  // Create parking lot (Admin only)
  Future<Map<String, dynamic>> createParkingLot({
    required String name,
    required Map<String, dynamic> address,
    required Map<String, dynamic> location,
    required int totalSpots,
    required Map<String, dynamic> pricing,
    List<String>? amenities,
    required Map<String, dynamic> operatingHours,
    Map<String, dynamic>? contactInfo,
  }) async {
    try {
      final response = await _apiService.post(
        '/parking',
        data: {
          'name': name,
          'address': address,
          'location': location,
          'totalSpots': totalSpots,
          'pricing': pricing,
          'amenities': amenities,
          'operatingHours': operatingHours,
          'contactInfo': contactInfo,
        },
      );

      if (response['success'] == true) {
        final parkingLot = ParkingLot.fromJson(response['data']['parkingLot']);

        return {
          'success': true,
          'parkingLot': parkingLot,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create parking lot',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Update parking lot (Admin only)
  Future<Map<String, dynamic>> updateParkingLot({
    required String parkingLotId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.put(
        '/parking/$parkingLotId',
        data: data,
      );

      if (response['success'] == true) {
        final parkingLot = ParkingLot.fromJson(response['data']['parkingLot']);

        return {
          'success': true,
          'parkingLot': parkingLot,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update parking lot',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Toggle favorite status for a parking lot
  Future<Map<String, dynamic>> toggleFavorite(String parkingLotId) async {
    try {
      final response = await _apiService.post(
        '/parking/$parkingLotId/favorite',
      );

      if (response['success'] == true) {
        final isFavorite = response['data']['isFavorite'] ?? false;

        return {
          'success': true,
          'isFavorite': isFavorite,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to toggle favorite status',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}
