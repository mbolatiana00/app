import 'package:app/core/result.dart';
import 'package:app/features/payment/domain/entities/payment_provider.dart';
import 'package:app/features/payment/domain/payment.dart';
import 'package:app/features/payment/domain/repositories/payment_repository.dart';
import 'package:app/features/payment/domain/usecases/initiate_payment.dart';
import 'package:app/features/payment/domain/usecases/watch_payment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRepo extends Mock implements PaymentRepository {}

Payment _p(PaymentStatus s) =>
    Payment(id: 1, orderId: 7, provider: PaymentProvider.mvola, status: s);

void main() {
  late MockPaymentRepo repo;
  setUp(() => repo = MockPaymentRepo());

  test('refuse un numéro qui ne correspond pas à l’opérateur', () async {
    final r = await InitiatePayment(repo)(
      orderId: 7,
      provider: PaymentProvider.mvola,
      phone: '0331234567', // 033 = Airtel
      idempotencyKey: 'k',
    );
    expect(r, isA<Err<Payment>>());
    verifyNever(
      () => repo.initiate(
        orderId: 7,
        provider: PaymentProvider.mvola,
        phone: '0331234567',
        idempotencyKey: 'k',
      ),
    );
  });

  test('WatchPayment s’arrête au statut final', () async {
    final answers = [
      Ok(_p(PaymentStatus.pending)),
      Ok(_p(PaymentStatus.succeeded)),
    ];
    when(() => repo.getPayment(1)).thenAnswer((_) async => answers.removeAt(0));

    final stream = WatchPayment(repo, interval: Duration.zero)(1);

    await expectLater(
      stream,
      emitsInOrder([isA<Ok<Payment>>(), isA<Ok<Payment>>(), emitsDone]),
    );
    verify(() => repo.getPayment(1)).called(2);
  });

  test('WatchPayment signale un délai dépassé', () async {
    when(() => repo.getPayment(1))
        .thenAnswer((_) async => Ok(_p(PaymentStatus.pending)));

    final results = await WatchPayment(
      repo,
      interval: Duration.zero,
      timeout: Duration.zero,
    )(1).toList();

    expect(results.last, isA<Err<Payment>>());
  });
}
