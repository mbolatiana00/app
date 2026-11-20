import 'package:app/features/Panier/domain/entities/cart_item.dart';
import 'package:app/features/orders/data/datasources/checkout_remote_datasource.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource _remote;
  const CheckoutRepositoryImpl(this._remote);

  @override
  Future<Result<PlacedOrder>> placeOrder({
    required List<CartItem> items,
    required String address,
    required String phone,
    required String idempotencyKey,
  }) async {
    try {
      final model = await _remote.place(
        items: items
            .map((i) => {'product_id': i.product.id, 'quantity': i.quantity})
            .toList(),
        address: address,
        phone: phone,
        idempotencyKey: idempotencyKey,
      );
      return Ok(model.toEntity());
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) return const Err(UnAuthorizeFailure());
      if (code == 400 || code == 422) {
        return const Err(ValidationFailure(
            'Commande refusée : vérifiez votre panier et vos informations'));
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Err(NetworkFailure());
      }
      return const Err(ServerFailure());
    } catch (_) {
      return const Err(ServerFailure());
    }
  }
}