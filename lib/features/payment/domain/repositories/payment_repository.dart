

import 'package:app/core/result.dart';
import 'package:app/features/payment/domain/entities/payment_provider.dart';
import 'package:app/features/payment/domain/payment.dart';

abstract class PaymentRepository {
  Future<Result<Payment>> initiate({
    required int orderId,
    required PaymentProvider provider,
    required String phone,
    required String idempotencyKey,
  });

  Future<Result<Payment>> getPayment(int id);
}