import 'package:app/features/Panier/domain/entities/cart_item.dart';



class Cart {
  final List<CartItem> items;
  const Cart([this.items = const []]);

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get total => items.fold(0.0, (sum, i) => sum + i.subtotal);

  int quantityOf(int productId) {
    for (final i in items) {
      if (i.product.id == productId) return i.quantity;
    }
    return 0;
  }
}