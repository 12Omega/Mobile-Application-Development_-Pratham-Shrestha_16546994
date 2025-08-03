class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final VehicleInfo? vehicleInfo;
  final UserPreferences? preferences;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const User({
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

  User copyWith({
    String? name,
    String? email,
    String? phone,
    VehicleInfo? vehicleInfo,
    UserPreferences? preferences,
    String? role,
    bool? isActive,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      preferences: preferences ?? this.preferences,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

class VehicleInfo {
  final String licensePlate;
  final String vehicleType;
  final String? color;
  final String? model;

  const VehicleInfo({
    required this.licensePlate,
    required this.vehicleType,
    this.color,
    this.model,
  });

  VehicleInfo copyWith({
    String? licensePlate,
    String? vehicleType,
    String? color,
    String? model,
  }) {
    return VehicleInfo(
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      color: color ?? this.color,
      model: model ?? this.model,
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

class UserPreferences {
  final bool notifications;
  final String theme;

  const UserPreferences({
    required this.notifications,
    required this.theme,
  });

  // Getters for compatibility
  bool get notificationsEnabled => notifications;
  bool get isDarkMode => theme == 'dark';

  UserPreferences copyWith({
    bool? notifications,
    String? theme,
    bool? notificationsEnabled,
    bool? isDarkMode,
  }) {
    return UserPreferences(
      notifications: notifications ?? notificationsEnabled ?? this.notifications,
      theme: isDarkMode != null
          ? (isDarkMode ? 'dark' : 'light')
          : theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'theme': theme,
    };
  }
}