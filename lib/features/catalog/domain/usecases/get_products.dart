

import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/catalog/domain/entities/product_page.dart';
import 'package:app/features/catalog/domain/repositories/product_repository.dart';

class GetProducts {
  final ProductRepository _repository;
  const GetProducts(this._repository);

  Future<Result<ProductPage>> call({required int page, String? query}) {
    if (page < 1) {
      return Future.value(const Err(ValidationFailure('Page invalide')));
    }
    final q = query?.trim();
    return _repository.getProducts(
      page: page,
      query: (q == null || q.isEmpty) ? null : q,
    );
  }
}