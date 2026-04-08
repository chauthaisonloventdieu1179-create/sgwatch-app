import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class BigSaleModel {
  final int id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final String? mediaType;
  final String? saleStartDate;
  final String? saleEndDate;
  final int? salePercentage;
  final bool isActive;
  final List<ProductModel> products;

  const BigSaleModel({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
    this.mediaType,
    this.saleStartDate,
    this.saleEndDate,
    this.salePercentage,
    this.isActive = true,
    this.products = const [],
  });

  factory BigSaleModel.fromJson(Map<String, dynamic> json) {
    final productList = json['products'] as List? ?? [];
    return BigSaleModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      mediaType: json['media_type']?.toString(),
      saleStartDate: json['sale_start_date']?.toString(),
      saleEndDate: json['sale_end_date']?.toString(),
      salePercentage: json['sale_percentage'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      products: productList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
