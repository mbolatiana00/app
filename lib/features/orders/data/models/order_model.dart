import '../../domain/entities/order.dart';

class OrderModel {
  final int id;
  final String title;
  final double total;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.title,
    required this.total,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as int,
    title: json['title'] as String,
    total: (json['total'] as num).toDouble(),
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
  );

  Order toEntity() =>
      Order(id: id, title: title, total: total, createdAt: createdAt);
}
