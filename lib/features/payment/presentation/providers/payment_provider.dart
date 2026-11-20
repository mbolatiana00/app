import 'dart:async';

import 'package:app/core/result.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/payment/data/datasource/payment_remote_datasource.dart';
import 'package:app/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:app/features/payment/domain/entities/payment_provider.dart';
import 'package:app/features/payment/domain/payment.dart';
import 'package:app/features/payment/domain/repositories/payment_repository.dart';
import 'package:app/features/payment/domain/usecases/initiate_payment.dart';
import 'package:app/features/payment/domain/usecases/watch_payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) =>
      PaymentRepositoryImpl(PaymentRemoteDataSource(ref.watch(dioProvider))),
);

enum PaymentPhase { idle, submitting, waiting, success, failed }

class PaymentUiState {
  final PaymentPhase phase;
  final String? message;
  const PaymentUiState(this.phase, [this.message]);
}

class PaymentController extends Notifier<PaymentUiState> {
  StreamSubscription<Result<Payment>>? _sub;
  String? _key;

  @override
  PaymentUiState build() {
    ref.onDispose(() => _sub?.cancel());
    return const PaymentUiState(PaymentPhase.idle);
  }

  PaymentRepository get _repo => ref.read(paymentRepositoryProvider);

  void reset() => state = const PaymentUiState(PaymentPhase.idle);

  Future<void> pay({
    required int orderId,
    required PaymentProvider provider,
    required String phone,
  }) async {
    if (state.phase == PaymentPhase.submitting ||
        state.phase == PaymentPhase.waiting) {
      return;
    }
    state = const PaymentUiState(PaymentPhase.submitting);
    _key ??= '$orderId-${DateTime.now().microsecondsSinceEpoch}';

    final result = await InitiatePayment(_repo)(
      orderId: orderId,
      provider: provider,
      phone: phone,
      idempotencyKey: _key!,
    );
    switch (result) {
      case Err(:final failure):
        state = PaymentUiState(PaymentPhase.failed, failure.message);
      case Ok(:final value):
        _key = null; // un nouvel essai créera un nouveau paiement
        _watch(value);
    }
  }

  void _watch(Payment payment) {
    state = const PaymentUiState(PaymentPhase.waiting);
    _sub?.cancel();
    _sub = WatchPayment(_repo)(payment.id).listen((r) {
      switch (r) {
        case Err(:final failure):
          state = PaymentUiState(PaymentPhase.failed, failure.message);
        case Ok(:final value):
          switch (value.status) {
            case PaymentStatus.succeeded:
              state = const PaymentUiState(PaymentPhase.success);
            case PaymentStatus.failed:
              state = PaymentUiState(
                PaymentPhase.failed,
                value.failureReason ?? 'Paiement refusé',
              );
            case PaymentStatus.pending:
              break;
          }
      }
    });
  }
}

final paymentControllerProvider =
    NotifierProvider.autoDispose<PaymentController, PaymentUiState>(
      PaymentController.new,
    );
