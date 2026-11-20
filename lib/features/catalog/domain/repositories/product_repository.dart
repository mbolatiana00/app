

import 'package:app/core/result.dart';
import 'package:app/features/catalog/domain/entities/product_page.dart';

abstract class ProductRepository {
  Future<Result<ProductPage>> getProducts({required int page, String? query});
}