import '../../core/models/payment_method.dart';
import '../../core/models/payment_method_type.dart' as core;
import '../../core/services/payment_repository.dart';
import '../remote/api_service.dart';
import '../models/payment_method_dto.dart' as dto;

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiService _apiService;

  PaymentRepositoryImpl(this._apiService);

  @override
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    try {
      final paymentDtos = await _apiService.getPaymentMethods(userId);
      return paymentDtos.map(_mapPaymentMethodDtoToPaymentMethod).toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  @override
  Future<PaymentMethod> addPaymentMethod(
      String userId, PaymentMethod paymentMethod) async {
    try {
      final paymentData = {
        'type': paymentMethod.type.toString().split('.').last,
        'displayName': paymentMethod.displayName,
        'last4Digits': paymentMethod.last4Digits,
        'expiryMonth': paymentMethod.expiryMonth.toString(),
        'expiryYear': paymentMethod.expiryYear.toString(),
        'isDefault': paymentMethod.isDefault,
      };

      final paymentDto =
          await _apiService.addPaymentMethod(userId, paymentData);
      return _mapPaymentMethodDtoToPaymentMethod(paymentDto);
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _apiService.deletePaymentMethod(paymentMethodId);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  PaymentMethod _mapPaymentMethodDtoToPaymentMethod(
      dto.PaymentMethodDto paymentDto) {
    return PaymentMethod(
      id: paymentDto.id,
      userId: paymentDto.userId,
      type: _mapPaymentMethodType(paymentDto.type),
      lastFour: paymentDto.last4Digits ?? '', // Handle nullable string
      displayName: paymentDto.displayName,
      last4Digits: paymentDto.last4Digits ?? '', // Handle nullable string
      expiryMonth: int.tryParse(paymentDto.expiryMonth ?? '') ??
          0, // Convert string to int
      expiryYear: int.tryParse(paymentDto.expiryYear ?? '') ??
          0, // Convert string to int
      isDefault: paymentDto.isDefault,
      createdAt: paymentDto.createdAt,
      updatedAt: paymentDto.updatedAt,
    );
  }

  core.PaymentMethodType _mapPaymentMethodType(dto.PaymentMethodType dtoType) {
    switch (dtoType) {
      case dto.PaymentMethodType.creditCard:
        return core.PaymentMethodType.creditCard;
      case dto.PaymentMethodType.debitCard:
        return core.PaymentMethodType.debitCard;
      case dto.PaymentMethodType.paypal:
        return core.PaymentMethodType.paypal;
      case dto.PaymentMethodType.applePay:
        return core.PaymentMethodType.applePay;
      case dto.PaymentMethodType.googlePay:
        return core.PaymentMethodType.googlePay;
    }
  }
}
