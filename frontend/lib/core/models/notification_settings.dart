// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports
// Use Clean Architecture version in features/profile/ instead

class NotificationSettings {
  final String id;
  final String userId;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool parkingReminders;
  final bool paymentAlerts;
  final bool promotionalOffers;
  final DateTime updatedAt;

  NotificationSettings({
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

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      pushNotifications: json['pushNotifications'] ?? false,
      emailNotifications: json['emailNotifications'] ?? false,
      smsNotifications: json['smsNotifications'] ?? false,
      parkingReminders: json['parkingReminders'] ?? false,
      paymentAlerts: json['paymentAlerts'] ?? false,
      promotionalOffers: json['promotionalOffers'] ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
