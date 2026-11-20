import 'package:app/features/payment/data/datasource/payment_remote_datasource.dart';
import 'package:app/features/payment/domain/payment.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../domain/entities/payment_provider.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remote;
  const PaymentRepositoryImpl(this._remote);

  Failure _map(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return const UnAuthorizeFailure();
      case 409:
        return const ValidationFailure('Cette commande est déjà payée');
      case 400:
      case 422:
        return const ValidationFailure('Paiement refusé : vérifiez le numéro');
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return const ServerFailure();
  }

  @override
  Future<Result<Payment>> initiate({
    required int orderId,
    required PaymentProvider provider,
    required String phone,
    required String idempotencyKey,
  }) async {
    try {
      final m = await _remote.initiate(
        orderId: orderId,
        provider: providerApiName(provider),
        phone: phone,
        idempotencyKey: idempotencyKey,
      );
      return Ok(m.toEntity());
    } on DioException catch (e) {
      return Err(_map(e));
    } catch (_) {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<Payment>> getPayment(int id) async {
    try {
      return Ok((await _remote.fetch(id)).toEntity());
    } on DioException catch (e) {
      return Err(_map(e));
    } catch (_) {
      return const Err(ServerFailure());
    }
  }
}