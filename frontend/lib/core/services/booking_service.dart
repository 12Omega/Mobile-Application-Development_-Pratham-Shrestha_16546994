import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/services/api_service.dart';

class BookingService {
  final ApiService _apiService;

  BookingService(this._apiService);

  // Generate mock bookings for development
  List<Booking> _generateMockBookings() {
    final now = DateTime.now();
    
    // Multiple vehicle types for variety
    final vehicles = [
      VehicleInfo(
        licensePlate: 'ABC123',
        vehicleType: 'sedan',
        model: 'Toyota Camry',
        color: 'Blue',
      ),
      VehicleInfo(
        licensePlate: 'XYZ789',
        vehicleType: 'suv',
        model: 'Honda CR-V',
        color: 'White',
      ),
      VehicleInfo(
        licensePlate: 'DEF456',
        vehicleType: 'compact',
        model: 'Nissan Sentra',
        color: 'Red',
      ),
      VehicleInfo(
        licensePlate: 'GHI321',
        vehicleType: 'truck',
        model: 'Ford F-150',
        color: 'Black',
      ),
      VehicleInfo(
        licensePlate: 'JKL654',
        vehicleType: 'electric',
        model: 'Tesla Model 3',
        color: 'Silver',
      ),
    ];

    return [
      // Active booking - currently parked
      _createMockBooking(
        id: 'booking_1',
        parkingLotId: 'parking_1',
        parkingLotName: 'Downtown Parking Plaza',
        spotNumber: 'A15',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 1)),
        baseAmount: 25.50,
        status: 'active',
        paymentMethod: 'credit_card',
        vehicleInfo: vehicles[0],
        createdAt: now.subtract(const Duration(hours: 2)),
        actualStartTime: now.subtract(const Duration(hours: 1, minutes: 55)),
        feedback: null,
        cancellation: null,
      ),
      
      // Completed booking with feedback
      _createMockBooking(
        id: 'booking_2',
        parkingLotId: 'parking_2',
        parkingLotName: 'City Center Garage',
        spotNumber: 'B08',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, hours: -4)),
        baseAmount: 48.00,
        status: 'completed',
        paymentMethod: 'credit_card',
        vehicleInfo: vehicles[1],
        createdAt: now.subtract(const Duration(days: 1)),
        actualStartTime: now.subtract(const Duration(days: 1, minutes: -5)),
        actualEndTime: now.subtract(const Duration(days: 1, hours: -3, minutes: -58)),
        feedback: FeedbackDetails(
          rating: 5,
          comment: 'Excellent parking spot, very convenient location and clean facilities.',
          submittedAt: now.subtract(const Duration(days: 1, hours: -3)),
        ),
      ),
      
      // Completed booking - short duration
      _createMockBooking(
        id: 'booking_3',
        parkingLotId: 'parking_3',
        parkingLotName: 'Quick Park Express',
        spotNumber: 'C22',
        startTime: now.subtract(const Duration(days: 3)),
        endTime: now.subtract(const Duration(days: 3, hours: -2)),
        baseAmount: 12.00,
        status: 'completed',
        paymentMethod: 'digital_wallet',
        vehicleInfo: vehicles[2],
        createdAt: now.subtract(const Duration(days: 3)),
        actualStartTime: now.subtract(const Duration(days: 3, minutes: -2)),
        actualEndTime: now.subtract(const Duration(days: 3, hours: -1, minutes: -58)),
        feedback: FeedbackDetails(
          rating: 4,
          comment: 'Good for quick stops, easy access.',
          submittedAt: now.subtract(const Duration(days: 3, hours: -1)),
        ),
      ),
      
      // Upcoming booking - reserved for tomorrow
      _createMockBooking(
        id: 'booking_4',
        parkingLotId: 'parking_4',
        parkingLotName: 'Premium Parking Tower',
        spotNumber: 'P01',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 6)),
        baseAmount: 90.00,
        status: 'upcoming',
        paymentMethod: 'credit_card',
        vehicleInfo: vehicles[3],
        createdAt: now,
      ),
      
      // Cancelled booking with refund
      _createMockBooking(
        id: 'booking_5',
        parkingLotId: 'parking_5',
        parkingLotName: 'Budget Parking Lot',
        spotNumber: 'D12',
        startTime: now.subtract(const Duration(days: 7)),
        endTime: now.subtract(const Duration(days: 7, hours: -8)),
        baseAmount: 32.00,
        status: 'cancelled',
        paymentMethod: 'cash',
        vehicleInfo: vehicles[4],
        createdAt: now.subtract(const Duration(days: 7)),
        cancellation: CancellationDetails(
          cancelledAt: now.subtract(const Duration(days: 7, hours: -1)),
          reason: 'Plans changed - meeting was cancelled',
          refundEligible: true,
        ),
      ),
      
      // No-show booking
      _createMockBooking(
        id: 'booking_6',
        parkingLotId: 'parking_1',
        parkingLotName: 'Downtown Parking Plaza',
        spotNumber: 'A22',
        startTime: now.subtract(const Duration(days: 5)),
        endTime: now.subtract(const Duration(days: 5, hours: -3)),
        baseAmount: 18.00,
        status: 'no_show',
        paymentMethod: 'credit_card',
        vehicleInfo: vehicles[0],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      
      // Long-term completed booking
      _createMockBooking(
        id: 'booking_7',
        parkingLotId: 'parking_2',
        parkingLotName: 'City Center Garage',
        spotNumber: 'B15',
        startTime: now.subtract(const Duration(days: 10)),
        endTime: now.subtract(const Duration(days: 10, hours: -12)),
        baseAmount: 144.00,
        status: 'completed',
        paymentMethod: 'credit_card',
        vehicleInfo: vehicles[1],
        createdAt: now.subtract(const Duration(days: 10)),
        actualStartTime: now.subtract(const Duration(days: 10, minutes: -3)),
        actualEndTime: now.subtract(const Duration(days: 10, hours: -11, minutes: -55)),
        feedback: FeedbackDetails(
          rating: 3,
          comment: 'Parking was okay but a bit expensive for the duration.',
          submittedAt: now.subtract(const Duration(days: 10, hours: -11)),
        ),
      ),
      
      // Recent completed booking - electric vehicle
      _createMockBooking(
        id: 'booking_8',
        parkingLotId: 'parking_6',
        parkingLotName: 'EcoCharge Station',
        spotNumber: 'E05',
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 4)),
        baseAmount: 32.00,
        status: 'completed',
        paymentMethod: 'digital_wallet',
        vehicleInfo: vehicles[4],
        createdAt: now.subtract(const Duration(hours: 8)),
        actualStartTime: now.subtract(const Duration(hours: 7, minutes: 58)),
        actualEndTime: now.subtract(const Duration(hours: 3, minutes: 59)),
        feedback: FeedbackDetails(
          rating: 5,
          comment: 'Perfect for electric vehicles! Fast charging available.',
          submittedAt: now.subtract(const Duration(hours: 3)),
        ),
      ),
    ];
  }

  Booking _createMockBooking({
    required String id,
    required String parkingLotId,
    required String parkingLotName,
    required String spotNumber,
    required DateTime startTime,
    required DateTime endTime,
    required double baseAmount,
    required String status,
    required String paymentMethod,
    required VehicleInfo vehicleInfo,
    required DateTime createdAt,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    FeedbackDetails? feedback,
    CancellationDetails? cancellation,
  }) {
    final duration = endTime.difference(startTime).inMinutes;
    final taxes = baseAmount * 0.08; // 8% tax
    final fees = _calculateFees(paymentMethod, baseAmount);
    final totalAmount = baseAmount + taxes + fees;

    // Determine payment status based on booking status
    String paymentStatus;
    DateTime? paidAt;
    DateTime? refundedAt;
    double? refundAmount;

    switch (status) {
      case 'cancelled':
        paymentStatus = cancellation?.refundEligible == true ? 'refunded' : 'paid';
        paidAt = createdAt;
        if (cancellation?.refundEligible == true) {
          refundedAt = cancellation!.cancelledAt;
          refundAmount = totalAmount * 0.9; // 90% refund (10% cancellation fee)
        }
        break;
      case 'no_show':
        paymentStatus = 'paid';
        paidAt = createdAt;
        break;
      case 'upcoming':
        paymentStatus = 'paid';
        paidAt = createdAt;
        break;
      default:
        paymentStatus = 'paid';
        paidAt = createdAt;
    }

    return Booking(
      id: id,
      userId: 'mock_user_123',
      parkingLotId: parkingLotId,
      spotNumber: spotNumber,
      vehicleInfo: vehicleInfo,
      bookingDetails: BookingDetails(
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        actualStartTime: actualStartTime,
        actualEndTime: actualEndTime,
      ),
      pricing: PricingDetails(
        baseAmount: baseAmount,
        taxes: taxes,
        fees: fees,
        totalAmount: totalAmount,
        currency: 'USD',
      ),
      payment: PaymentDetails(
        method: paymentMethod,
        status: paymentStatus,
        transactionId: 'txn_${id}_${DateTime.now().millisecondsSinceEpoch}',
        paidAt: paidAt,
        refundedAt: refundedAt,
        refundAmount: refundAmount,
      ),
      status: status,
      qrCode: 'QR_${id.toUpperCase()}_${parkingLotId.toUpperCase()}',
      notifications: NotificationStatus(
        reminderSent: status != 'upcoming',
        arrivalNotified: status == 'active' || status == 'completed' || status == 'no_show',
        completionNotified: status == 'completed',
      ),
      feedback: feedback,
      cancellation: cancellation,
      createdAt: createdAt.toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      user: _getMockUser(),
      parkingLot: _getMockParkingLot(parkingLotId, parkingLotName),
    );
  }

  // Calculate fees based on payment method and amount
  double _calculateFees(String paymentMethod, double baseAmount) {
    switch (paymentMethod) {
      case 'credit_card':
        return 1.50 + (baseAmount * 0.029); // Fixed fee + 2.9%
      case 'digital_wallet':
        return 1.00 + (baseAmount * 0.025); // Fixed fee + 2.5%
      case 'cash':
        return 0.50; // Minimal processing fee
      default:
        return 1.50;
    }
  }

  // Generate mock user data
  Map<String, dynamic> _getMockUser() {
    return {
      '_id': 'mock_user_123',
      'name': 'John Smith',
      'email': 'john.smith@email.com',
      'phone': '+1 (555) 123-4567',
      'role': 'user',
      'isActive': true,
      'createdAt': '2024-01-15T10:30:00.000Z',
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Generate comprehensive parking lot data
  Map<String, dynamic> _getMockParkingLot(String parkingLotId, String parkingLotName) {
    final baseData = {
      '_id': parkingLotId,
      'name': parkingLotName,
      'address': _getMockAddress(parkingLotId),
      'contact': _getMockContact(parkingLotId),
      'amenities': _getMockAmenities(parkingLotId),
      'operatingHours': _getMockOperatingHours(parkingLotId),
      'pricing': _getMockParkingLotPricing(parkingLotId),
      'totalSpots': _getTotalSpots(parkingLotId),
      'availableSpots': _getAvailableSpots(parkingLotId),
      'rating': _getParkingLotRating(parkingLotId),
      'coordinates': _getMockCoordinates(parkingLotId),
    };

    return baseData;
  }

  Map<String, String> _getMockAddress(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1':
        return {
          'street': '123 Main Street',
          'city': 'Downtown',
          'state': 'NY',
          'zipCode': '10001',
          'country': 'United States',
        };
      case 'parking_2':
        return {
          'street': '456 Broadway',
          'city': 'Midtown',
          'state': 'NY',
          'zipCode': '10002',
          'country': 'United States',
        };
      case 'parking_3':
        return {
          'street': '789 Park Avenue',
          'city': 'Uptown',
          'state': 'NY',
          'zipCode': '10003',
          'country': 'United States',
        };
      case 'parking_4':
        return {
          'street': '321 Fifth Avenue',
          'city': 'Manhattan',
          'state': 'NY',
          'zipCode': '10004',
          'country': 'United States',
        };
      case 'parking_5':
        return {
          'street': '654 Second Street',
          'city': 'Brooklyn',
          'state': 'NY',
          'zipCode': '10005',
          'country': 'United States',
        };
      case 'parking_6':
        return {
          'street': '987 Green Street',
          'city': 'EcoDistrict',
          'state': 'NY',
          'zipCode': '10006',
          'country': 'United States',
        };
      default:
        return {
          'street': 'Unknown Street',
          'city': 'Unknown City',
          'state': 'NY',
          'zipCode': '10000',
          'country': 'United States',
        };
    }
  }

  Map<String, String> _getMockContact(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1':
        return {
          'phone': '+1 (555) 101-2001',
          'email': 'info@downtownplaza.com',
          'website': 'www.downtownplaza.com',
        };
      case 'parking_2':
        return {
          'phone': '+1 (555) 102-2002',
          'email': 'support@citycentergarage.com',
          'website': 'www.citycentergarage.com',
        };
      case 'parking_3':
        return {
          'phone': '+1 (555) 103-2003',
          'email': 'help@quickparkexpress.com',
          'website': 'www.quickparkexpress.com',
        };
      case 'parking_4':
        return {
          'phone': '+1 (555) 104-2004',
          'email': 'concierge@premiumparking.com',
          'website': 'www.premiumparking.com',
        };
      case 'parking_5':
        return {
          'phone': '+1 (555) 105-2005',
          'email': 'info@budgetparking.com',
          'website': 'www.budgetparking.com',
        };
      case 'parking_6':
        return {
          'phone': '+1 (555) 106-2006',
          'email': 'support@ecocharge.com',
          'website': 'www.ecocharge.com',
        };
      default:
        return {
          'phone': '+1 (555) 000-0000',
          'email': 'info@parking.com',
          'website': 'www.parking.com',
        };
    }
  }

  List<String> _getMockAmenities(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1':
        return ['24/7 Security', 'CCTV Surveillance', 'Covered Parking', 'Elevator Access', 'Restrooms'];
      case 'parking_2':
        return ['Valet Service', 'Car Wash', 'EV Charging', 'WiFi', 'Covered Parking', 'Security'];
      case 'parking_3':
        return ['Quick Entry/Exit', 'Mobile Payment', 'Security Cameras', 'Well Lit'];
      case 'parking_4':
        return ['Valet Service', 'Concierge', 'Car Detailing', 'EV Charging', 'Premium Security', 'Climate Control'];
      case 'parking_5':
        return ['Basic Security', 'Affordable Rates', 'Easy Access'];
      case 'parking_6':
        return ['Fast EV Charging', 'Solar Powered', 'Green Building', 'Tesla Superchargers', 'Eco-Friendly'];
      default:
        return ['Basic Parking'];
    }
  }

  Map<String, String> _getMockOperatingHours(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1':
      case 'parking_2':
      case 'parking_4':
        return {
          'monday': '24 Hours',
          'tuesday': '24 Hours',
          'wednesday': '24 Hours',
          'thursday': '24 Hours',
          'friday': '24 Hours',
          'saturday': '24 Hours',
          'sunday': '24 Hours',
        };
      case 'parking_3':
        return {
          'monday': '6:00 AM - 10:00 PM',
          'tuesday': '6:00 AM - 10:00 PM',
          'wednesday': '6:00 AM - 10:00 PM',
          'thursday': '6:00 AM - 10:00 PM',
          'friday': '6:00 AM - 11:00 PM',
          'saturday': '7:00 AM - 11:00 PM',
          'sunday': '8:00 AM - 9:00 PM',
        };
      case 'parking_5':
        return {
          'monday': '7:00 AM - 9:00 PM',
          'tuesday': '7:00 AM - 9:00 PM',
          'wednesday': '7:00 AM - 9:00 PM',
          'thursday': '7:00 AM - 9:00 PM',
          'friday': '7:00 AM - 10:00 PM',
          'saturday': '8:00 AM - 10:00 PM',
          'sunday': '9:00 AM - 8:00 PM',
        };
      case 'parking_6':
        return {
          'monday': '24 Hours',
          'tuesday': '24 Hours',
          'wednesday': '24 Hours',
          'thursday': '24 Hours',
          'friday': '24 Hours',
          'saturday': '24 Hours',
          'sunday': '24 Hours',
        };
      default:
        return {
          'monday': '8:00 AM - 6:00 PM',
          'tuesday': '8:00 AM - 6:00 PM',
          'wednesday': '8:00 AM - 6:00 PM',
          'thursday': '8:00 AM - 6:00 PM',
          'friday': '8:00 AM - 6:00 PM',
          'saturday': '9:00 AM - 5:00 PM',
          'sunday': 'Closed',
        };
    }
  }

  Map<String, dynamic> _getMockParkingLotPricing(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1':
        return {
          'hourlyRate': 8.50,
          'dailyRate': 45.00,
          'weeklyRate': 280.00,
          'monthlyRate': 950.00,
          'currency': 'USD',
        };
      case 'parking_2':
        return {
          'hourlyRate': 12.00,
          'dailyRate': 65.00,
          'weeklyRate': 420.00,
          'monthlyRate': 1400.00,
          'currency': 'USD',
        };
      case 'parking_3':
        return {
          'hourlyRate': 6.00,
          'dailyRate': 30.00,
          'weeklyRate': 180.00,
          'monthlyRate': 650.00,
          'currency': 'USD',
        };
      case 'parking_4':
        return {
          'hourlyRate': 15.00,
          'dailyRate': 85.00,
          'weeklyRate': 550.00,
          'monthlyRate': 1800.00,
          'currency': 'USD',
        };
      case 'parking_5':
        return {
          'hourlyRate': 4.00,
          'dailyRate': 20.00,
          'weeklyRate': 120.00,
          'monthlyRate': 400.00,
          'currency': 'USD',
        };
      case 'parking_6':
        return {
          'hourlyRate': 8.00,
          'dailyRate': 40.00,
          'weeklyRate': 250.00,
          'monthlyRate': 850.00,
          'currency': 'USD',
        };
      default:
        return {
          'hourlyRate': 8.00,
          'dailyRate': 40.00,
          'weeklyRate': 240.00,
          'monthlyRate': 800.00,
          'currency': 'USD',
        };
    }
  }

  int _getTotalSpots(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1': return 250;
      case 'parking_2': return 180;
      case 'parking_3': return 75;
      case 'parking_4': return 120;
      case 'parking_5': return 300;
      case 'parking_6': return 50;
      default: return 100;
    }
  }

  int _getAvailableSpots(String parkingLotId) {
    final total = _getTotalSpots(parkingLotId);
    // Simulate varying availability
    switch (parkingLotId) {
      case 'parking_1': return (total * 0.3).round(); // 30% available
      case 'parking_2': return (total * 0.15).round(); // 15% available
      case 'parking_3': return (total * 0.6).round(); // 60% available
      case 'parking_4': return (total * 0.25).round(); // 25% available
      case 'parking_5': return (total * 0.8).round(); // 80% available
      case 'parking_6': return (total * 0.4).round(); // 40% available
      default: return (total * 0.5).round(); // 50% available
    }
  }

  double _getParkingLotRating(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1': return 4.2;
      case 'parking_2': return 4.7;
      case 'parking_3': return 3.8;
      case 'parking_4': return 4.9;
      case 'parking_5': return 3.5;
      case 'parking_6': return 4.6;
      default: return 4.0;
    }
  }

  Map<String, double> _getMockCoordinates(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1':
        return {'latitude': 40.7589, 'longitude': -73.9851};
      case 'parking_2':
        return {'latitude': 40.7505, 'longitude': -73.9934};
      case 'parking_3':
        return {'latitude': 40.7831, 'longitude': -73.9712};
      case 'parking_4':
        return {'latitude': 40.7614, 'longitude': -73.9776};
      case 'parking_5':
        return {'latitude': 40.6892, 'longitude': -73.9442};
      case 'parking_6':
        return {'latitude': 40.7282, 'longitude': -73.9942};
      default:
        return {'latitude': 40.7128, 'longitude': -74.0060};
    }
  }

  // Get recent bookings
  Future<Map<String, dynamic>> getRecentBookings() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Faster loading
    
    final mockBookings = _generateMockBookings().take(5).toList();
    
    return {
      'success': true,
      'bookings': mockBookings,
    };
  }

  // Create booking
  Future<Map<String, dynamic>> createBooking({
    required String parkingLotId,
    required String spotNumber,
    required DateTime startTime,
    required DateTime endTime,
    required VehicleInfo vehicleInfo,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Faster booking
    
    final duration = endTime.difference(startTime).inHours;
    final hourlyRate = _getHourlyRateForParkingLot(parkingLotId);
    final totalAmount = duration * hourlyRate;
    
    final newBooking = _createMockBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      parkingLotId: parkingLotId,
      parkingLotName: _getParkingLotName(parkingLotId),
      spotNumber: spotNumber,
      startTime: startTime,
      endTime: endTime,
      baseAmount: totalAmount,
      status: 'upcoming',
      paymentMethod: paymentMethod,
      vehicleInfo: vehicleInfo,
      createdAt: DateTime.now(),
    );

    return {
      'success': true,
      'booking': newBooking,
    };
  }

  double _getHourlyRateForParkingLot(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1': return 8.50;
      case 'parking_2': return 12.00;
      case 'parking_3': return 6.00;
      case 'parking_4': return 15.00;
      case 'parking_5': return 4.00;
      default: return 8.00;
    }
  }

  String _getParkingLotName(String parkingLotId) {
    switch (parkingLotId) {
      case 'parking_1': return 'Downtown Parking Plaza';
      case 'parking_2': return 'City Center Garage';
      case 'parking_3': return 'Quick Park Express';
      case 'parking_4': return 'Premium Parking Tower';
      case 'parking_5': return 'Budget Parking Lot';
      default: return 'Unknown Parking Lot';
    }
  }

  // Get user bookings
  Future<Map<String, dynamic>> getUserBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150)); // Faster loading
    
    var mockBookings = _generateMockBookings();
    
    // Filter by status if provided
    if (status != null) {
      mockBookings = mockBookings.where((booking) => booking.status == status).toList();
    }
    
    // Paginate results
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedBookings = mockBookings.skip(startIndex).take(limit).toList();
    
    return {
      'success': true,
      'bookings': paginatedBookings,
      'count': paginatedBookings.length,
      'total': mockBookings.length,
      'pages': (mockBookings.length / limit).ceil(),
      'currentPage': page,
    };
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Fast loading
    
    // Find the booking from mock data
    final mockBookings = _generateMockBookings();
    final booking = mockBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => mockBookings.first, // Return first booking if not found
    );

    return {
      'success': true,
      'booking': booking,
    };
  }

  // Cancel booking
  Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mock cancellation
    final mockBookings = _generateMockBookings();
    var booking = mockBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => mockBookings.first,
    );

    return {
      'success': true,
      'booking': booking,
      'message': 'Booking cancelled successfully',
    };
  }

  // Check in to booking
  Future<Map<String, dynamic>> checkInBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mock check-in
    final mockBookings = _generateMockBookings();
    var booking = mockBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => mockBookings.first,
    );

    return {
      'success': true,
      'booking': booking,
      'message': 'Checked in successfully',
    };
  }

  // Check out from booking
  Future<Map<String, dynamic>> checkOutBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mock check-out
    final mockBookings = _generateMockBookings();
    var booking = mockBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => mockBookings.first,
    );

    return {
      'success': true,
      'booking': booking,
      'message': 'Checked out successfully',
    };
  }

  // Submit feedback
  Future<Map<String, dynamic>> submitFeedback({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mock feedback submission
    final mockBookings = _generateMockBookings();
    var booking = mockBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => mockBookings.first,
    );

    return {
      'success': true,
      'booking': booking,
      'message': 'Feedback submitted successfully',
    };
  }
}