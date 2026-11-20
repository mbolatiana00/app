import 'product.dart';

class ProductPage {
  final List<Product> items;
  final int page;
  final bool hasMore;

  const ProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });
}