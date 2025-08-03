// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports
// Use Clean Architecture version in features/profile/ instead

import 'payment_method_type.dart';

class PaymentMethod {
  final String id;
  final String? userId;
  final PaymentMethodType type;
  final String lastFour;
  final bool isDefault;
  final String displayName;
  final String last4Digits;
  final int expiryMonth;
  final int expiryYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    this.userId,
    required this.type,
    required this.lastFour,
    required this.isDefault,
    required this.displayName,
    required this.last4Digits,
    required this.expiryMonth,
    required this.expiryYear,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      userId: json['userId'],
      type: _parsePaymentMethodType(json['type']),
      lastFour: json['lastFour'] ?? '',
      isDefault: json['isDefault'] ?? false,
      displayName: json['displayName'] ?? '',
      last4Digits: json['last4Digits'] ?? '',
      expiryMonth: json['expiryMonth'] ?? 0,
      expiryYear: json['expiryYear'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static PaymentMethodType _parsePaymentMethodType(dynamic type) {
    if (type is PaymentMethodType) return type;
    final typeStr = type?.toString() ?? '';
    switch (typeStr.toLowerCase()) {
      case 'creditcard':
      case 'credit_card':
        return PaymentMethodType.creditCard;
      case 'debitcard':
      case 'debit_card':
        return PaymentMethodType.debitCard;
      case 'bankaccount':
      case 'bank_account':
        return PaymentMethodType.bankAccount;
      case 'paypal':
        return PaymentMethodType.paypal;
      case 'applepay':
      case 'apple_pay':
        return PaymentMethodType.applePay;
      case 'googlepay':
      case 'google_pay':
        return PaymentMethodType.googlePay;
      default:
        return PaymentMethodType.creditCard;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'lastFour': lastFour,
      'isDefault': isDefault,
      'displayName': displayName,
      'last4Digits': last4Digits,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
