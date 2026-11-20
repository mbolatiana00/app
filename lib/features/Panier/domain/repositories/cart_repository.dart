
import 'package:app/features/Panier/domain/cart.dart';

abstract class CartRepository {
  Cart load();
  Future<void> save(Cart cart);
}