import '../../../../core/result.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> getOrders();

  Future<Result<Order>> createOrder({
    required String title,
    required double total,
  });
}
