import 'package:app/core/result.dart';
import 'package:app/features/catalog/domain/entities/product_page.dart';
import 'package:app/features/catalog/domain/repositories/product_repository.dart';
import 'package:app/features/catalog/domain/usecases/get_products.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepo extends Mock implements ProductRepository {}

void main() {
  late MockProductRepo repo;
  late GetProducts usecase;
  const empty = ProductPage(items: [], page: 1, hasMore: false);

  setUp(() {
    repo = MockProductRepo();
    usecase = GetProducts(repo);
  });

  test('refuse une page inférieure à 1', () async {
    expect(await usecase(page: 0), isA<Err<ProductPage>>());
    verifyNever(() => repo.getProducts(
        page: any(named: 'page'), query: any(named: 'query')));
  });

  test('nettoie la recherche et ignore une recherche vide', () async {
    when(() => repo.getProducts(page: 1, query: 'riz'))
        .thenAnswer((_) async => const Ok(empty));
    when(() => repo.getProducts(page: 1, query: null))
        .thenAnswer((_) async => const Ok(empty));

    await usecase(page: 1, query: '  riz ');
    await usecase(page: 1, query: '   ');

    verify(() => repo.getProducts(page: 1, query: 'riz')).called(1);
    verify(() => repo.getProducts(page: 1, query: null)).called(1);
  });
}