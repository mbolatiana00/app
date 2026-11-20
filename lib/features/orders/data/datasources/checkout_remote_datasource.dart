import 'package:dio/dio.dart';
import '../models/placed_order_model.dart';

class CheckoutRemoteDataSource {
  final Dio _dio;
  const CheckoutRemoteDataSource(this._dio);

  Future<PlacedOrderModel> place({
    required List<Map<String, dynamic>> items,
    required String address,
    required String phone,
    required String idempotencyKey,
  }) async {
    final r = await _dio.post(
      '/checkout',
      data: {'items': items, 'address': address, 'phone': phone},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PlacedOrderModel.fromJson(r.data as Map<String, dynamic>);
  }
}