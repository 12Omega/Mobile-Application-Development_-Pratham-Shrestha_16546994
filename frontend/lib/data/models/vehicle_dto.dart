class VehicleDto {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String? nickname;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleDto({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.nickname,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      nickname: json['nickname'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'nickname': nickname,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}