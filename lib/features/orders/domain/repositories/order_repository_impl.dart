import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../entities/order.dart';
import 'order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;

  const OrderRepositoryImpl(this._remote);

  @override
  Future<Result<List<Order>>> getOrders() async {
    try {
      final models = await _remote.fetchAll();
      return Ok(models.map((model) => model.toEntity()).toList());
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return const Err(NetworkFailure());
      }
      return const Err(ServerFailure());
    } catch (_) {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<Order>> createOrder({
    required String title,
    required double total,
  }) async {
    try {
      final model = await _remote.postOrder(title, total);
      return Ok(model.toEntity());
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 400 || code == 422) {
        return const Err(ValidationFailure('Commande invalide'));
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return const Err(NetworkFailure());
      }
      return const Err(ServerFailure('Création impossible'));
    } catch (_) {
      return const Err(ServerFailure('Création impossible'));
    }
  }
}
