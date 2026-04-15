int _parseProdInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class AdminProductModel {
  final int id;
  final String name;
  final String? sku;
  final int categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final int priceJpy;
  final int? originalPriceJpy;
  final int? costPriceJpy;
  final int? points;
  final String? primaryImageUrl;
  final List<AdminProductImageModel> images;
  final int stockQuantity;
  final String stockType;
  final bool isNew;
  final bool isDomestic;
  final String? gender;
  final String? movementType;
  final int? warrantyMonths;
  final Map<String, dynamic>? attributes;
  final String? description;
  final String? productInfo;
  final String? dealInfo;
  final int? displayOrder;

  const AdminProductModel({
    required this.id,
    required this.name,
    this.sku,
    required this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    required this.priceJpy,
    this.originalPriceJpy,
    this.costPriceJpy,
    this.points,
    this.primaryImageUrl,
    required this.images,
    required this.stockQuantity,
    required this.stockType,
    required this.isNew,
    required this.isDomestic,
    this.gender,
    this.movementType,
    this.warrantyMonths,
    this.attributes,
    this.description,
    this.productInfo,
    this.dealInfo,
    this.displayOrder,
  });

  factory AdminProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final brand = json['brand'] as Map<String, dynamic>?;

    return AdminProductModel(
      id: _parseProdInt(json['id']),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      categoryId: _parseProdInt(json['category_id'] ?? category?['id']),
      categoryName: json['category_name']?.toString() ?? category?['name']?.toString(),
      brandId: json['brand_id'] != null
          ? _parseProdInt(json['brand_id'])
          : (brand != null ? _parseProdInt(brand['id']) : null),
      brandName: json['brand_name']?.toString() ?? brand?['name']?.toString(),
      priceJpy: _parseProdInt(json['price_jpy'] ?? json['price']),
      originalPriceJpy: (json['original_price_jpy'] ?? json['original_price']) != null
          ? _parseProdInt(json['original_price_jpy'] ?? json['original_price'])
          : null,
      costPriceJpy: json['cost_price_jpy'] != null
          ? _parseProdInt(json['cost_price_jpy'])
          : null,
      points: json['points'] != null ? _parseProdInt(json['points']) : null,
      primaryImageUrl: json['primary_image_url']?.toString(),
      images: (json['images'] as List? ?? [])
          .map((e) => AdminProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stockQuantity: _parseProdInt(json['stock_quantity']),
      stockType: json['stock_type']?.toString() ?? 'in_stock',
      isNew: json['is_new'] as bool? ?? true,
      isDomestic: json['is_domestic'] as bool? ?? false,
      gender: json['gender']?.toString(),
      movementType: json['movement_type']?.toString(),
      warrantyMonths: json['warranty_months'] != null
          ? _parseProdInt(json['warranty_months'])
          : null,
      attributes: json['attributes'] as Map<String, dynamic>?,
      description: json['description']?.toString(),
      productInfo: json['product_info']?.toString(),
      dealInfo: json['deal_info']?.toString(),
      displayOrder: json['display_order'] != null
          ? _parseProdInt(json['display_order'])
          : null,
    );
  }
}

class AdminProductImageModel {
  final int id;
  final String url;

  const AdminProductImageModel({required this.id, required this.url});

  factory AdminProductImageModel.fromJson(Map<String, dynamic> json) {
    return AdminProductImageModel(
      id: _parseProdInt(json['id']),
      url: json['url']?.toString() ?? json['image_url']?.toString() ?? '',
    );
  }
}

class AdminBrandModel {
  final int id;
  final String name;
  final String slug;

  const AdminBrandModel({required this.id, required this.name, required this.slug});

  factory AdminBrandModel.fromJson(Map<String, dynamic> json) {
    return AdminBrandModel(
      id: _parseProdInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class AdminCategoryModel {
  final int id;
  final String name;
  final String slug;

  const AdminCategoryModel({required this.id, required this.name, required this.slug});

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryModel(
      id: _parseProdInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}
