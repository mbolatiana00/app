import 'package:app/features/Panier/data/models/datasources/cart_local_datasource.dart';
import 'package:app/features/Panier/data/models/datasources/repositories/cart_repository_impl.dart';
import 'package:app/features/Panier/domain/cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../../catalog/domain/entities/product.dart';

import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) =>
      CartRepositoryImpl(CartLocalDataSource(ref.watch(sharedPrefsProvider))),
);

class CartController extends Notifier<Cart> {
  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  Cart build() => _repo.load();

  /// Retourne null si tout va bien, sinon l'erreur à afficher.
  Failure? add(Product p) => _apply(const AddToCart()(state, p));

  Failure? setQuantity(Product p, int quantity) =>
      _apply(const SetQuantity()(state, p, quantity));

  void clear() {
    state = const Cart();
    _repo.save(state);
  }

  Failure? _apply(Result<Cart> result) {
    switch (result) {
      case Ok(:final value):
        state = value;
        _repo.save(value);
        return null;
      case Err(:final failure):
        return failure;
    }
  }
}

final cartControllerProvider = NotifierProvider<CartController, Cart>(
  CartController.new,
);

final cartCountProvider = Provider(
  (ref) => ref.watch(cartControllerProvider).itemCount,
);
