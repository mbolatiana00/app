

import 'package:app/features/Panier/data/models/datasources/cart_local_datasource.dart';
import 'package:app/features/Panier/domain/cart.dart';
import 'package:app/features/Panier/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _local;
  const CartRepositoryImpl(this._local);

  @override
  Cart load() => Cart(_local.read());

  @override
  Future<void> save(Cart cart) => _local.write(cart.items);
}