class Order {
  final int id;
  final String title;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.title,
    required this.total,
    required this.createdAt,
  });
}
