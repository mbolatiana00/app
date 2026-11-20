
import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/core/validators/phone_validator.dart';
import 'package:app/features/Panier/domain/entities/cart_item.dart';
import 'package:app/features/orders/domain/entities/placed_order.dart';
import 'package:app/features/orders/domain/repositories/checkout_repository.dart';

class PlaceOrder {
  final CheckoutRepository _repository;
  const PlaceOrder(this._repository);

  Future<Result<PlacedOrder>> call({
    required List<CartItem> items,
    required String address,
    required String phone,
    required String idempotencyKey,
  }) {
    Future<Result<PlacedOrder>> fail(String m) =>
        Future.value(Err(ValidationFailure(m)));

    if (items.isEmpty) return fail('Votre panier est vide');
    if (address.trim().length < 5) return fail('Adresse de livraison trop courte');
    if (!isValidMalagasyPhone(phone)) {
      return fail('Téléphone invalide (ex : 034 12 345 67)');
    }
    return _repository.placeOrder(
      items: items,
      address: address.trim(),
      phone: normalizePhone(phone),
      idempotencyKey: idempotencyKey,
    );
  }
}