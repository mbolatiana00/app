import 'package:app/features/catalog/data/models/product_model.dart';
import 'package:dio/dio.dart';

typedef ProductsPayload = ({
  List<ProductModel> items,
  int page,
  int totalPages,
});

class ProductRemoteDataSource {
  final Dio _dio;
  const ProductRemoteDataSource(this._dio);

  Future<ProductsPayload> fetch({required int page, String? query}) async {
    final r = await _dio.get(
      '/products',
      queryParameters: {'page': page, 'limit': 20, 'q': ?query},
    );
    final data = r.data as Map<String, dynamic>;
    return (
      items: (data['data'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: data['page'] as int,
      totalPages: data['total_pages'] as int,
    );
  }
}
