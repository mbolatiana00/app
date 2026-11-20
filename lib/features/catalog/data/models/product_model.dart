

import 'package:app/features/catalog/domain/entities/product.dart';

class ProductModel {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['image_url'] as String?,
      );

  Product toEntity() =>
      Product(id: id, name: name, price: price, imageUrl: imageUrl);
}