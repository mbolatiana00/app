import 'package:app/features/payment/domain/entities/payment_provider.dart';



enum PaymentStatus { pending, succeeded, failed }

class Payment {
  final int id;
  final int orderId;
  final PaymentProvider provider;
  final PaymentStatus status;
  final String? failureReason;

  const Payment({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.status,
    this.failureReason,
  });
}