

import 'package:app/core/result.dart';
import 'package:app/features/Panier/domain/entities/cart_item.dart';
import 'package:app/features/orders/domain/entities/placed_order.dart';

abstract class CheckoutRepository {
  Future<Result<PlacedOrder>> placeOrder({
    required List<CartItem> items,
    required String address,
    required String phone,
    required String idempotencyKey,
  });
}