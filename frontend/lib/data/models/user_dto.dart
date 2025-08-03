// Data Transfer Object for User API responses
class UserDto {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String createdAt;
  final String updatedAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VehicleDto {
  final String id;
  final String make;
  final String model;
  final String color;
  final String licensePlate;
  final String type;
  final bool isDefault;
  final String createdAt;

  const VehicleDto({
    required this.id,
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      type: json['type'] as String,
      isDefault: json['isDefault'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'type': type,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }
}

class PaymentMethodDto {
  final String id;
  final String type;
  final String displayName;
  final String lastFourDigits;
  final String? expiryDate;
  final bool isDefault;
  final String createdAt;

  const PaymentMethodDto({
    required this.id,
    required this.type,
    required this.displayName,
    required this.lastFourDigits,
    this.expiryDate,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentMethodDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDto(
      id: json['id'] as String,
      type: json['type'] as String,
      displayName: json['displayName'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      expiryDate: json['expiryDate'] as String?,
      isDefault: json['isDefault'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'displayName': displayName,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }
}

class NotificationSettingsDto {
  final bool allNotifications;
  final bool parkingUpdates;
  final bool bookingReminders;
  final bool promotionalOffers;
  final bool securityAlerts;

  const NotificationSettingsDto({
    required this.allNotifications,
    required this.parkingUpdates,
    required this.bookingReminders,
    required this.promotionalOffers,
    required this.securityAlerts,
  });

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsDto(
      allNotifications: json['allNotifications'] as bool,
      parkingUpdates: json['parkingUpdates'] as bool,
      bookingReminders: json['bookingReminders'] as bool,
      promotionalOffers: json['promotionalOffers'] as bool,
      securityAlerts: json['securityAlerts'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allNotifications': allNotifications,
      'parkingUpdates': parkingUpdates,
      'bookingReminders': bookingReminders,
      'promotionalOffers': promotionalOffers,
      'securityAlerts': securityAlerts,
    };
  }
}