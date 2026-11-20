

import 'package:app/features/orders/domain/entities/placed_order.dart';

class PlacedOrderModel {
  final int id;
  final double total;
  final String status;

  const PlacedOrderModel({
    required this.id,
    required this.total,
    required this.status,
  });

  factory PlacedOrderModel.fromJson(Map<String, dynamic> json) =>
      PlacedOrderModel(
        id: json['id'] as int,
        total: (json['total'] as num).toDouble(),
        status: json['status'] as String,
      );

  PlacedOrder toEntity() => PlacedOrder(
        id: id,
        total: total,
        status: switch (status) {
          'paid' => OrderStatus.paid,
          'cancelled' => OrderStatus.cancelled,
          _ => OrderStatus.pendingPayment,
        },
      );
}