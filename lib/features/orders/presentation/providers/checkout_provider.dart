import 'package:app/core/result.dart';
import 'package:app/features/Panier/presentation/providers/cart_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/orders/data/datasources/checkout_remote_datasource.dart';
import 'package:app/features/orders/domain/entities/placed_order.dart';
import 'package:app/features/orders/domain/repositories/checkout_repository.dart';
import 'package:app/features/orders/domain/repositories/checkout_repository_impl.dart';
import 'package:app/features/orders/domain/usecases/place_order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) =>
      CheckoutRepositoryImpl(CheckoutRemoteDataSource(ref.watch(dioProvider))),
);

class CheckoutController extends AsyncNotifier<PlacedOrder?> {
  String? _key; // même clé tant que la commande n'a pas réussi

  @override
  Future<PlacedOrder?> build() async => null;

  Future<PlacedOrder?> submit({
    required String address,
    required String phone,
  }) async {
    if (state.isLoading) return null; // anti double-clic
    state = const AsyncLoading();
    _key ??= DateTime.now().microsecondsSinceEpoch.toString();
    final cart = ref.read(cartControllerProvider);

    final result = await PlaceOrder(ref.read(checkoutRepositoryProvider))(
      items: cart.items,
      address: address,
      phone: phone,
      idempotencyKey: _key!,
    );

    switch (result) {
      case Ok(:final value):
        _key = null;
        ref.read(cartControllerProvider.notifier).clear();
        state = AsyncData(value);
        return value;
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
        return null;
    }
  }
}

final checkoutControllerProvider =
    AsyncNotifierProvider.autoDispose<CheckoutController, PlacedOrder?>(
      CheckoutController.new,
    );
