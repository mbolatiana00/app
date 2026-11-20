

import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/Panier/domain/cart.dart';
import 'package:app/features/Panier/domain/entities/cart_item.dart';
import 'package:app/features/catalog/domain/entities/product.dart';

const maxQuantityPerProduct = 20;

class SetQuantity {
  const SetQuantity();

  Result<Cart> call(Cart cart, Product product, int quantity) {
    if (quantity > maxQuantityPerProduct) {
      return const Err(
          ValidationFailure('Maximum $maxQuantityPerProduct par produit'));
    }
    if (quantity <= 0) {
      return Ok(Cart(
          cart.items.where((i) => i.product.id != product.id).toList()));
    }
    final exists = cart.items.any((i) => i.product.id == product.id);
    final items = exists
        ? cart.items
            .map((i) => i.product.id == product.id
                ? i.copyWith(quantity: quantity)
                : i)
            .toList()
        : [...cart.items, CartItem(product: product, quantity: quantity)];
    return Ok(Cart(items));
  }
}

class AddToCart {
  const AddToCart();

  Result<Cart> call(Cart cart, Product product) =>
      const SetQuantity()(cart, product, cart.quantityOf(product.id) + 1);
}