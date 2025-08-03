// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports

enum PaymentMethodType {
  creditCard,
  debitCard,
  bankAccount,
  paypal,
  applePay,
  googlePay,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get displayName {
    switch (this) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.bankAccount:
        return 'Bank Account';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
    }
  }
}
