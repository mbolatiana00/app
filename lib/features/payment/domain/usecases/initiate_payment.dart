
import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/core/validators/phone_validator.dart';
import 'package:app/features/payment/domain/entities/payment_provider.dart';
import 'package:app/features/payment/domain/payment.dart';
import 'package:app/features/payment/domain/repositories/payment_repository.dart';

class InitiatePayment {
  final PaymentRepository _repository;
  const InitiatePayment(this._repository);

  Future<Result<Payment>> call({
    required int orderId,
    required PaymentProvider provider,
    required String phone,
    required String idempotencyKey,
  }) {
    Future<Result<Payment>> fail(String m) =>
        Future.value(Err(ValidationFailure(m)));

    if (!isValidMalagasyPhone(phone)) {
      return fail('Téléphone invalide (ex : 034 12 345 67)');
    }
    final clean = normalizePhone(phone);
    if (!provider.prefixes.contains(clean.substring(0, 3))) {
      return fail("Ce numéro n'est pas un numéro ${provider.label}");
    }
    return _repository.initiate(
      orderId: orderId,
      provider: provider,
      phone: clean,
      idempotencyKey: idempotencyKey,
    );
  }
}