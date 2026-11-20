import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/catalog/data/datasources/product_remote_datasource.dart';
import 'package:app/features/catalog/domain/entities/product_page.dart';
import 'package:app/features/catalog/domain/repositories/product_repository.dart';
import 'package:dio/dio.dart';


class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  const ProductRepositoryImpl(this._remote);

  @override
  Future<Result<ProductPage>> getProducts({
    required int page,
    String? query,
  }) async {
    try {
      final p = await _remote.fetch(page: page, query: query);
      return Ok(ProductPage(
        items: p.items.map((m) => m.toEntity()).toList(),
        page: p.page,
        hasMore: p.page < p.totalPages,
      ));
    } on DioException catch (e) {
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