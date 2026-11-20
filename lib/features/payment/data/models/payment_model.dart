import 'package:app/features/payment/domain/payment.dart';

import '../../domain/entities/payment_provider.dart';

String providerApiName(PaymentProvider p) => switch (p) {
      PaymentProvider.mvola => 'mvola',
      PaymentProvider.orangeMoney => 'orange_money',
      PaymentProvider.airtelMoney => 'airtel_money',
    };

class PaymentModel {
  final int id;
  final int orderId;
  final String provider;
  final String status;
  final String? failureReason;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.status,
    this.failureReason,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        provider: json['provider'] as String,
        status: json['status'] as String,
        failureReason: json['failure_reason'] as String?,
      );

  Payment toEntity() => Payment(
        id: id,
        orderId: orderId,
        provider: switch (provider) {
          'orange_money' => PaymentProvider.orangeMoney,
          'airtel_money' => PaymentProvider.airtelMoney,
          _ => PaymentProvider.mvola,
        },
        status: switch (status) {
          'succeeded' => PaymentStatus.succeeded,
          'failed' => PaymentStatus.failed,
          _ => PaymentStatus.pending,
        },
        failureReason: failureReason,
      );
}