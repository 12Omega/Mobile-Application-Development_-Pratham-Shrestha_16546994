import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingLot {
  final String id;
  final String name;
  final Address address;
  final Location location;
  final int totalSpots;
  final int availableSpots;
  final List<ParkingSpot> spots;
  final Pricing pricing;
  final List<String> amenities;
  final OperatingHours operatingHours;
  final ContactInfo contactInfo;
  final bool isActive;
  final String managedBy;
  final String createdAt;
  final String updatedAt;
  bool isFavorite;

  ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.totalSpots,
    required this.availableSpots,
    required this.spots,
    required this.pricing,
    required this.amenities,
    required this.operatingHours,
    required this.contactInfo,
    required this.isActive,
    required this.managedBy,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot(
      id: json['_id'],
      name: json['name'],
      address: Address.fromJson(json['address']),
      location: Location.fromJson(json['location']),
      totalSpots: json['totalSpots'],
      availableSpots: json['availableSpots'],
      spots: (json['spots'] as List<dynamic>?)
              ?.map((spot) => ParkingSpot.fromJson(spot))
              .toList() ??
          [],
      pricing: Pricing.fromJson(json['pricing']),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((amenity) => amenity.toString())
              .toList() ??
          [],
      operatingHours: OperatingHours.fromJson(json['operatingHours']),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      isActive: json['isActive'] ?? true,
      managedBy: json['managedBy'] is String
          ? json['managedBy']
          : json['managedBy']?['_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address.toJson(),
      'location': location.toJson(),
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
      'spots': spots.map((spot) => spot.toJson()).toList(),
      'pricing': pricing.toJson(),
      'amenities': amenities,
      'operatingHours': operatingHours.toJson(),
      'contactInfo': contactInfo.toJson(),
      'isActive': isActive,
      'managedBy': managedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite,
    };
  }

  LatLng get latLng => LatLng(
        location.coordinates[1],
        location.coordinates[0],
      );

  String get fullAddress =>
      '${address.street}, ${address.city}, ${address.state} ${address.zipCode}';

  String get availabilityText => '$availableSpots/$totalSpots spots available';

  double get occupancyRate =>
      ((totalSpots - availableSpots) / totalSpots) * 100;

  String get formattedHourlyRate =>
      '\$${pricing.hourlyRate.toStringAsFixed(2)}';

  bool get hasElectricCharging => amenities.contains('ev_charging');

  bool get hasCovered => amenities.contains('covered');

  bool get hasSecurity => amenities.contains('security');

  bool get is24Hours => operatingHours.is24Hours;

  String get operatingHoursText => is24Hours
      ? 'Open 24 hours'
      : 'Open ${operatingHours.open} - ${operatingHours.close}';
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'USA',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'] ?? 'USA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final coordsList = (json['coordinates'] as List<dynamic>)
        .map((coord) => coord is int ? coord.toDouble() : coord as double)
        .toList();

    return Location(
      type: json['type'],
      coordinates: coordsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class ParkingSpot {
  final String spotNumber;
  final String type;
  final bool isAvailable;
  final bool isReserved;
  final String? reservedBy;
  final String? reservedUntil;
  final SpotCoordinates? coordinates;

  ParkingSpot({
    required this.spotNumber,
    required this.type,
    required this.isAvailable,
    required this.isReserved,
    this.reservedBy,
    this.reservedUntil,
    this.coordinates,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      spotNumber: json['spotNumber'],
      type: json['type'],
      isAvailable: json['isAvailable'],
      isReserved: json['isReserved'],
      reservedBy: json['reservedBy'],
      reservedUntil: json['reservedUntil'],
      coordinates: json['coordinates'] != null
          ? SpotCoordinates.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotNumber': spotNumber,
      'type': type,
      'isAvailable': isAvailable,
      'isReserved': isReserved,
      'reservedBy': reservedBy,
      'reservedUntil': reservedUntil,
      'coordinates': coordinates?.toJson(),
    };
  }

  bool get isAvailableForBooking => isAvailable && !isReserved;
}

class SpotCoordinates {
  final double latitude;
  final double longitude;

  SpotCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory SpotCoordinates.fromJson(Map<String, dynamic> json) {
    return SpotCoordinates(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Pricing {
  final double hourlyRate;
  final double dailyRate;
  final String currency;

  Pricing({
    required this.hourlyRate,
    required this.dailyRate,
    this.currency = 'USD',
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      hourlyRate: json['hourlyRate'].toDouble(),
      dailyRate: json['dailyRate'].toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'currency': currency,
    };
  }
}

class OperatingHours {
  final String open;
  final String close;
  final bool is24Hours;

  OperatingHours({
    required this.open,
    required this.close,
    this.is24Hours = false,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      open: json['open'],
      close: json['close'],
      is24Hours: json['is24Hours'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
      'is24Hours': is24Hours,
    };
  }
}

class ContactInfo {
  final String? phone;
  final String? email;

  ContactInfo({
    this.phone,
    this.email,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
    };
  }
}
