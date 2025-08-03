class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final VehicleInfo vehicleInfo;
  final UserPreferences preferences;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleInfo,
    required this.preferences,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      vehicleInfo: VehicleInfo.fromJson(json['vehicleInfo']),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleInfo': vehicleInfo.toJson(),
      'preferences': preferences.toJson(),
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  User copyWith({
    String? name,
    String? phone,
    VehicleInfo? vehicleInfo,
    UserPreferences? preferences,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: this.email,
      phone: phone ?? this.phone,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      preferences: preferences ?? this.preferences,
      role: this.role,
      isActive: this.isActive,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }
}

class VehicleInfo {
  final String licensePlate;
  final String vehicleType;
  final String? color;
  final String? model;

  VehicleInfo({
    required this.licensePlate,
    required this.vehicleType,
    this.color,
    this.model,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
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
      'color': color ?? 'Not specified',
      'model': model ?? 'Not specified',
    };
  }

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
}

class UserPreferences {
  final bool notifications;
  final String theme;
  final bool? emailNotifications;
  final bool? bookingReminders;
  final bool? promotionalOffers;

  UserPreferences({
    this.notifications = true,
    this.theme = 'system',
    this.emailNotifications,
    this.bookingReminders,
    this.promotionalOffers,
    bool? notificationsEnabled,
    bool? isDarkMode,
  });

  // Getters for compatibility
  bool get notificationsEnabled => notifications;
  bool get isDarkMode => theme == 'dark';

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notifications: json['notifications'] ?? true,
      theme: json['theme'] ?? 'system',
      emailNotifications: json['emailNotifications'],
      bookingReminders: json['bookingReminders'],
      promotionalOffers: json['promotionalOffers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'theme': theme,
      'emailNotifications': emailNotifications,
      'bookingReminders': bookingReminders,
      'promotionalOffers': promotionalOffers,
    };
  }

  UserPreferences copyWith({
    bool? notifications,
    String? theme,
    bool? emailNotifications,
    bool? bookingReminders,
    bool? promotionalOffers,
    bool? notificationsEnabled,
    bool? isDarkMode,
  }) {
    return UserPreferences(
      notifications:
          notifications ?? notificationsEnabled ?? this.notifications,
      theme: isDarkMode != null
          ? (isDarkMode ? 'dark' : 'light')
          : theme ?? this.theme,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      bookingReminders: bookingReminders ?? this.bookingReminders,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
    );
  }
}
