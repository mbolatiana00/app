import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel {
  static Map<String, dynamic> toJson(CartItem i) => {
        'id': i.product.id,
        'name': i.product.name,
        'price': i.product.price,
        'image_url': i.product.imageUrl,
        'quantity': i.quantity,
      };

  static CartItem fromJson(Map<String, dynamic> j) => CartItem(
        product: Product(
          id: j['id'] as int,
          name: j['name'] as String,
          price: (j['price'] as num).toDouble(),
          imageUrl: j['image_url'] as String?,
        ),
        quantity: j['quantity'] as int,
      );
}