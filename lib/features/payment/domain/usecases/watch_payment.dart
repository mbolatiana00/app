

import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/payment/domain/payment.dart';
import 'package:app/features/payment/domain/repositories/payment_repository.dart';

/// Émet l'état du paiement jusqu'à un statut final ou un délai dépassé.
class WatchPayment {
  final PaymentRepository _repository;
  final Duration interval;
  final Duration timeout;

  const WatchPayment(
    this._repository, {
    this.interval = const Duration(seconds: 3),
    this.timeout = const Duration(minutes: 2),
  });

  Stream<Result<Payment>> call(int paymentId) async* {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final result = await _repository.getPayment(paymentId);
      yield result;
      if (result is! Ok<Payment>) return;
      if (result.value.status != PaymentStatus.pending) return;
      if (DateTime.now().isAfter(deadline)) {
        yield const Err(PaymentTimeoutFailure());
        return;
      }
      await Future.delayed(interval);
    }
  }
}