enum PaymentMethodType { creditCard, debitCard, paypal, applePay, googlePay }

class PaymentMethodDto {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String displayName;
  final String? last4Digits;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethodDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.displayName,
    this.last4Digits,
    this.expiryMonth,
    this.expiryYear,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      displayName: json['displayName'] as String,
      last4Digits: json['last4Digits'] as String?,
      expiryMonth: json['expiryMonth'] as String?,
      expiryYear: json['expiryYear'] as String?,
      isDefault: json['isDefault'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'displayName': displayName,
      'last4Digits': last4Digits,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}