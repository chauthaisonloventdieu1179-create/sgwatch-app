import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class CollectionModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final List<ProductModel> products;

  const CollectionModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.products = const [],
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List? ?? [];
    return CollectionModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      products: productsList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
