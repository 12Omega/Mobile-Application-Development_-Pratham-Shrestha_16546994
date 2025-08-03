import 'package:parkease/core/models/user_model.dart';

class Booking {
  final String id;
  final String userId;
  final String parkingLotId;
  final String spotNumber;
  final VehicleInfo vehicleInfo;
  final BookingDetails bookingDetails;
  final PricingDetails pricing;
  final PaymentDetails payment;
  final String status;
  final String qrCode;
  final NotificationStatus notifications;
  final FeedbackDetails? feedback;
  final CancellationDetails? cancellation;
  final String createdAt;
  final String updatedAt;

  // Populated fields
  final dynamic user;
  final dynamic parkingLot;

  Booking({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    required this.spotNumber,
    required this.vehicleInfo,
    required this.bookingDetails,
    required this.pricing,
    required this.payment,
    required this.status,
    required this.qrCode,
    required this.notifications,
    this.feedback,
    this.cancellation,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.parkingLot,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      userId: json['user'] is String ? json['user'] : json['user']['_id'],
      parkingLotId: json['parkingLot'] is String
          ? json['parkingLot']
          : json['parkingLot']['_id'],
      spotNumber: json['spotNumber'],
      vehicleInfo: VehicleInfo.fromJson(json['vehicleInfo']),
      bookingDetails: BookingDetails.fromJson(json['bookingDetails']),
      pricing: PricingDetails.fromJson(json['pricing']),
      payment: PaymentDetails.fromJson(json['payment']),
      status: json['status'],
      qrCode: json['qrCode'] ?? '',
      notifications: NotificationStatus.fromJson(json['notifications'] ?? {}),
      feedback: json['feedback'] != null
          ? FeedbackDetails.fromJson(json['feedback'])
          : null,
      cancellation: json['cancellation'] != null
          ? CancellationDetails.fromJson(json['cancellation'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['user'] is! String ? json['user'] : null,
      parkingLot: json['parkingLot'] is! String ? json['parkingLot'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'parkingLot': parkingLotId,
      'spotNumber': spotNumber,
      'vehicleInfo': vehicleInfo.toJson(),
      'bookingDetails': bookingDetails.toJson(),
      'pricing': pricing.toJson(),
      'payment': payment.toJson(),
      'status': status,
      'qrCode': qrCode,
      'notifications': notifications.toJson(),
      'feedback': feedback?.toJson(),
      'cancellation': cancellation?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isActive => status == 'active';
  bool get isReserved => status == 'reserved';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isNoShow => status == 'no_show';

  String get formattedTotalAmount =>
      '\$${pricing.totalAmount.toStringAsFixed(2)}';

  String get parkingLotName {
    if (parkingLot != null && parkingLot is Map<String, dynamic>) {
      return parkingLot['name'] ?? 'Unknown Parking Lot';
    }
    return 'Unknown Parking Lot';
  }

  String get formattedAddress {
    if (parkingLot != null &&
        parkingLot is Map<String, dynamic> &&
        parkingLot['address'] != null) {
      final address = parkingLot['address'];
      return '${address['street']}, ${address['city']}, ${address['state']} ${address['zipCode']}';
    }
    return '';
  }
}

class BookingDetails {
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;

  BookingDetails({
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.actualStartTime,
    this.actualEndTime,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'],
      actualStartTime: json['actualStartTime'] != null
          ? DateTime.parse(json['actualStartTime'])
          : null,
      actualEndTime: json['actualEndTime'] != null
          ? DateTime.parse(json['actualEndTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'actualStartTime': actualStartTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
    };
  }
}

class PricingDetails {
  final double baseAmount;
  final double taxes;
  final double fees;
  final double totalAmount;
  final String currency;

  PricingDetails({
    required this.baseAmount,
    required this.taxes,
    required this.fees,
    required this.totalAmount,
    this.currency = 'USD',
  });

  factory PricingDetails.fromJson(Map<String, dynamic> json) {
    return PricingDetails(
      baseAmount: json['baseAmount'].toDouble(),
      taxes: json['taxes'].toDouble(),
      fees: json['fees'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseAmount': baseAmount,
      'taxes': taxes,
      'fees': fees,
      'totalAmount': totalAmount,
      'currency': currency,
    };
  }
}

class PaymentDetails {
  final String method;
  final String status;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final double? refundAmount;

  PaymentDetails({
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
    this.refundedAt,
    this.refundAmount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      method: json['method'],
      status: json['status'],
      transactionId: json['transactionId'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
      refundAmount: json['refundAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'paidAt': paidAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'refundAmount': refundAmount,
    };
  }
}

class NotificationStatus {
  final bool reminderSent;
  final bool arrivalNotified;
  final bool completionNotified;

  NotificationStatus({
    this.reminderSent = false,
    this.arrivalNotified = false,
    this.completionNotified = false,
  });

  factory NotificationStatus.fromJson(Map<String, dynamic> json) {
    return NotificationStatus(
      reminderSent: json['reminderSent'] ?? false,
      arrivalNotified: json['arrivalNotified'] ?? false,
      completionNotified: json['completionNotified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderSent': reminderSent,
      'arrivalNotified': arrivalNotified,
      'completionNotified': completionNotified,
    };
  }
}

class FeedbackDetails {
  final int rating;
  final String? comment;
  final DateTime submittedAt;

  FeedbackDetails({
    required this.rating,
    this.comment,
    required this.submittedAt,
  });

  factory FeedbackDetails.fromJson(Map<String, dynamic> json) {
    return FeedbackDetails(
      rating: json['rating'],
      comment: json['comment'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}

class CancellationDetails {
  final DateTime cancelledAt;
  final String? reason;
  final bool refundEligible;

  CancellationDetails({
    required this.cancelledAt,
    this.reason,
    required this.refundEligible,
  });

  factory CancellationDetails.fromJson(Map<String, dynamic> json) {
    return CancellationDetails(
      cancelledAt: DateTime.parse(json['cancelledAt']),
      reason: json['reason'],
      refundEligible: json['refundEligible'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cancelledAt': cancelledAt.toIso8601String(),
      'reason': reason,
      'refundEligible': refundEligible,
    };
  }
}
