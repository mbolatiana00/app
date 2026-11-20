enum OrderStatus { pendingPayment, paid, cancelled }

class PlacedOrder {
  final int id;
  final double total;
  final OrderStatus status;

  const PlacedOrder({
    required this.id,
    required this.total,
    required this.status,
  });
}