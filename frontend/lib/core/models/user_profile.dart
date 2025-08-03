class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        profileImageUrl.hashCode;
  }
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final String color;
  final String licensePlate;
  final String type; // sedan, suv, truck, etc.
  final bool isDefault;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
  });

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    String? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName => '$make $model';
  String get fullDescription => '$color $make $model - $licensePlate';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'type': type,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      type: json['type'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, make: $make, model: $model, licensePlate: $licensePlate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle &&
        other.id == id &&
        other.make == make &&
        other.model == model &&
        other.color == color &&
        other.licensePlate == licensePlate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        make.hashCode ^
        model.hashCode ^
        color.hashCode ^
        licensePlate.hashCode;
  }
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String displayName;
  final String lastFourDigits;
  final String? expiryDate;
  final bool isDefault;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.lastFourDigits,
    this.expiryDate,
    this.isDefault = false,
    required this.createdAt,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? displayName,
    String? lastFourDigits,
    String? expiryDate,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get maskedNumber {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return '**** **** **** $lastFourDigits';
      case PaymentMethodType.bankAccount:
        return '**** $lastFourDigits';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'displayName': displayName,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      displayName: json['displayName'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      expiryDate: json['expiryDate'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'PaymentMethod(id: $id, type: $type, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod &&
        other.id == id &&
        other.type == type &&
        other.displayName == displayName &&
        other.lastFourDigits == lastFourDigits;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        displayName.hashCode ^
        lastFourDigits.hashCode;
  }
}

enum PaymentMethodType {
  creditCard,
  debitCard,
  bankAccount,
}

class NotificationSettings {
  final bool allNotifications;
  final bool parkingUpdates;
  final bool bookingReminders;
  final bool promotionalOffers;
  final bool securityAlerts;

  const NotificationSettings({
    this.allNotifications = true,
    this.parkingUpdates = true,
    this.bookingReminders = true,
    this.promotionalOffers = false,
    this.securityAlerts = true,
  });

  NotificationSettings copyWith({
    bool? allNotifications,
    bool? parkingUpdates,
    bool? bookingReminders,
    bool? promotionalOffers,
    bool? securityAlerts,
  }) {
    return NotificationSettings(
      allNotifications: allNotifications ?? this.allNotifications,
      parkingUpdates: parkingUpdates ?? this.parkingUpdates,
      bookingReminders: bookingReminders ?? this.bookingReminders,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      securityAlerts: securityAlerts ?? this.securityAlerts,
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

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      allNotifications: json['allNotifications'] as bool? ?? true,
      parkingUpdates: json['parkingUpdates'] as bool? ?? true,
      bookingReminders: json['bookingReminders'] as bool? ?? true,
      promotionalOffers: json['promotionalOffers'] as bool? ?? false,
      securityAlerts: json['securityAlerts'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(allNotifications: $allNotifications, parkingUpdates: $parkingUpdates, bookingReminders: $bookingReminders, promotionalOffers: $promotionalOffers, securityAlerts: $securityAlerts)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.allNotifications == allNotifications &&
        other.parkingUpdates == parkingUpdates &&
        other.bookingReminders == bookingReminders &&
        other.promotionalOffers == promotionalOffers &&
        other.securityAlerts == securityAlerts;
  }

  @override
  int get hashCode {
    return allNotifications.hashCode ^
        parkingUpdates.hashCode ^
        bookingReminders.hashCode ^
        promotionalOffers.hashCode ^
        securityAlerts.hashCode;
  }
}
