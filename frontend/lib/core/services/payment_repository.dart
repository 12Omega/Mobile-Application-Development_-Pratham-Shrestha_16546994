// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports
// Use Clean Architecture version in features/profile/ instead

import '../models/payment_method.dart';

abstract class PaymentRepository {
  Future<List<PaymentMethod>> getPaymentMethods(String userId);
  Future<PaymentMethod> addPaymentMethod(
      String userId, PaymentMethod paymentMethod);
  Future<void> deletePaymentMethod(String paymentMethodId);
}
