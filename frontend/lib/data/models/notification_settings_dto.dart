class NotificationSettingsDto {
  final String id;
  final String userId;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool parkingReminders;
  final bool paymentAlerts;
  final bool promotionalOffers;
  final DateTime updatedAt;

  NotificationSettingsDto({
    required this.id,
    required this.userId,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.parkingReminders,
    required this.paymentAlerts,
    required this.promotionalOffers,
    required this.updatedAt,
  });

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      pushNotifications: json['pushNotifications'] as bool,
      emailNotifications: json['emailNotifications'] as bool,
      smsNotifications: json['smsNotifications'] as bool,
      parkingReminders: json['parkingReminders'] as bool,
      paymentAlerts: json['paymentAlerts'] as bool,
      promotionalOffers: json['promotionalOffers'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'parkingReminders': parkingReminders,
      'paymentAlerts': paymentAlerts,
      'promotionalOffers': promotionalOffers,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
