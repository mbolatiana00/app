import 'package:dio/dio.dart';
import '../models/payment_model.dart';

class PaymentRemoteDataSource {
  final Dio _dio;
  const PaymentRemoteDataSource(this._dio);

  Future<PaymentModel> initiate({
    required int orderId,
    required String provider,
    required String phone,
    required String idempotencyKey,
  }) async {
    final r = await _dio.post(
      '/payments',
      data: {'order_id': orderId, 'provider': provider, 'phone': phone},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PaymentModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<PaymentModel> fetch(int id) async {
    final r = await _dio.get('/payments/$id');
    return PaymentModel.fromJson(r.data as Map<String, dynamic>);
  }
}