import 'package:app/core/result.dart';
import 'package:app/features/Panier/domain/entities/cart_item.dart';
import 'package:app/features/catalog/domain/entities/product.dart';
import 'package:app/features/orders/domain/entities/placed_order.dart';
import 'package:app/features/orders/domain/repositories/checkout_repository.dart';
import 'package:app/features/orders/domain/usecases/place_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepository {}

void main() {
  late MockCheckoutRepo repo;
  late PlaceOrder usecase;
  const items = [
    CartItem(product: Product(id: 1, name: 'Riz', price: 3000), quantity: 2),
  ];

  setUp(() {
    repo = MockCheckoutRepo();
    usecase = PlaceOrder(repo);
  });

  test('refuse un panier vide', () async {
    final r = await usecase(
        items: [], address: 'Lot 12 Analakely', phone: '0341234567', idempotencyKey: 'k');
    expect(r, isA<Err<PlacedOrder>>());
  });

  test('refuse un téléphone invalide', () async {
    final r = await usecase(
        items: items, address: 'Lot 12 Analakely', phone: '0612345678', idempotencyKey: 'k');
    expect(r, isA<Err<PlacedOrder>>());
    verifyNever(() => repo.placeOrder(
        items: any(named: 'items'),
        address: any(named: 'address'),
        phone: any(named: 'phone'),
        idempotencyKey: any(named: 'idempotencyKey')));
  });

  test('envoie un téléphone normalisé', () async {
    const order =
        PlacedOrder(id: 7, total: 6000, status: OrderStatus.pendingPayment);
    when(() => repo.placeOrder(
          items: items,
          address: 'Lot 12 Analakely',
          phone: '0341234567',
          idempotencyKey: 'k',
        )).thenAnswer((_) async => const Ok(order));

    final r = await usecase(
        items: items,
        address: ' Lot 12 Analakely ',
        phone: '034 12 345 67',
        idempotencyKey: 'k');
    expect(r, isA<Ok<PlacedOrder>>());
  });
}