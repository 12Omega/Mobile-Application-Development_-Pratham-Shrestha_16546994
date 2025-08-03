// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports
// Use Clean Architecture version in features/profile/ instead

class Vehicle {
  final String id;
  final String make;
  final String model;
  final String licensePlate;
  final String color;
  final int year;
  final String nickname;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.year,
    required this.nickname,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      color: json['color'] ?? '',
      year: json['year'] ?? 0,
      nickname: json['nickname'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'licensePlate': licensePlate,
      'color': color,
      'year': year,
      'nickname': nickname,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
