import 'package:dio/dio.dart';

import '../models/order_model.dart';

class OrderRemoteDataSource {
  final Dio _dio;

  const OrderRemoteDataSource(this._dio);

  Future<List<OrderModel>> fetchAll() async {
    final response = await _dio.get('/orders');
    final data = response.data;
    final items = data is Map<String, dynamic>
        ? data['data'] as List<dynamic>? ?? const <dynamic>[]
        : data as List<dynamic>;

    return items
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> postOrder(String title, double total) async {
    final response = await _dio.post(
      '/orders',
      data: {'title': title, 'total': total},
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
