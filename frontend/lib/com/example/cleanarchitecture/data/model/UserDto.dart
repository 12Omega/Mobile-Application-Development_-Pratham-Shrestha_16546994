// Data Transfer Object for User API responses
class UserDto {
  final String id;
  final String name;
  final String email;
  final String phone;
  final VehicleInfoDto? vehicleInfo;
  final UserPreferencesDto? preferences;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.vehicleInfo,
    this.preferences,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      vehicleInfo: json['vehicleInfo'] != null 
          ? VehicleInfoDto.fromJson(json['vehicleInfo']) 
          : null,
      preferences: json['preferences'] != null 
          ? UserPreferencesDto.fromJson(json['preferences']) 
          : null,
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleInfo': vehicleInfo?.toJson(),
      'preferences': preferences?.toJson(),
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VehicleInfoDto {
  final String licensePlate;
  final String vehicleType;
  final String? color;
  final String? model;

  const VehicleInfoDto({
    required this.licensePlate,
    required this.vehicleType,
    this.color,
    this.model,
  });

  factory VehicleInfoDto.fromJson(Map<String, dynamic> json) {
    return VehicleInfoDto(
      licensePlate: json['licensePlate'],
      vehicleType: json['vehicleType'],
      color: json['color'],
      model: json['model'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'color': color,
      'model': model,
    };
  }
}

class UserPreferencesDto {
  final bool notifications;
  final String theme;

  const UserPreferencesDto({
    required this.notifications,
    required this.theme,
  });

  factory UserPreferencesDto.fromJson(Map<String, dynamic> json) {
    return UserPreferencesDto(
      notifications: json['notifications'] ?? true,
      theme: json['theme'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'theme': theme,
    };
  }
}