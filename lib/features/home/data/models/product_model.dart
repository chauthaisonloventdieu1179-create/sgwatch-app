class ProductModel {
  final int id;
  final String name;
  final String? slug;
  final String? sku;
  final String? shortDescription;
  final String? description;
  final String? productInfo;
  final String? dealInfo;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double? priceVnd;
  final double? originalPriceVnd;
  final int? points;
  final String? gender;
  final String? movementType;
  final String? condition;
  final int? stockQuantity;
  final int? warrantyMonths;
  final bool? isFeatured;
  final bool? isFavorited;
  final double? averageRating;
  final int? reviewCount;
  final int? viewCount;
  final int? soldCount;
  final String? brandName;
  final String? brandSlug;
  final String? categoryName;
  final String? categorySlug;
  final bool? isPurchased;
  final List<ProductImage>? images;
  final double? salePercent;
  final Map<String, dynamic>? attributes;
  final String? stockType;
  final List<GroupedProduct>? groupedProducts;

  const ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.slug,
    this.sku,
    this.shortDescription,
    this.description,
    this.productInfo,
    this.dealInfo,
    this.originalPrice,
    this.priceVnd,
    this.originalPriceVnd,
    this.points,
    this.gender,
    this.movementType,
    this.condition,
    this.stockQuantity,
    this.warrantyMonths,
    this.isFeatured,
    this.isFavorited,
    this.averageRating,
    this.reviewCount,
    this.viewCount,
    this.soldCount,
    this.brandName,
    this.brandSlug,
    this.categoryName,
    this.categorySlug,
    this.isPurchased,
    this.images,
    this.salePercent,
    this.attributes,
    this.stockType,
    this.groupedProducts,
  });

  bool get isPreOrder => stockType == 'pre_order';
  bool get isCarnival => brandName == 'Carnival' || brandSlug == 'Carnival';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;
    final imagesList = json['images'] as List?;

    // primary_image_url from list API, or first image from detail API
    String imageUrl = (json['primary_image_url'] ?? json['image_url'])?.toString() ?? '';
    List<ProductImage>? images;
    if (imagesList != null) {
      images = imagesList
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList();
      // If no primary_image_url, use first primary image
      if (imageUrl.isEmpty && images.isNotEmpty) {
        final primary = images.where((i) => i.isPrimary).firstOrNull;
        imageUrl = (primary ?? images.first).imageUrl;
      }
    }

    return ProductModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      sku: json['sku']?.toString(),
      shortDescription: json['short_description']?.toString(),
      description: json['description']?.toString(),
      productInfo: json['product_info']?.toString(),
      dealInfo: json['deal_info']?.toString(),
      imageUrl: imageUrl,
      price: _parseDouble(json['price_jpy'] ?? json['price']),
      originalPrice: _parseNullableDouble(json['original_price_jpy'] ?? json['original_price']),
      priceVnd: _parseNullableDouble(json['price_vnd']),
      originalPriceVnd: _parseNullableDouble(json['original_price_vnd']),
      points: json['points'] as int?,
      gender: json['gender']?.toString(),
      movementType: json['movement_type']?.toString(),
      condition: json['condition']?.toString(),
      stockQuantity: json['stock_quantity'] as int?,
      warrantyMonths: json['warranty_months'] as int?,
      isFeatured: json['is_featured'] as bool?,
      isFavorited: json['is_favorited'] as bool?,
      isPurchased: json['is_purchased'] as bool?,
      averageRating: _parseNullableDouble(json['average_rating']),
      reviewCount: json['review_count'] as int?,
      viewCount: json['view_count'] as int?,
      soldCount: json['sold_count'] as int?,
      brandName: brand?['name']?.toString(),
      brandSlug: brand?['slug']?.toString(),
      categoryName: category?['name']?.toString(),
      categorySlug: category?['slug']?.toString(),
      images: images,
      salePercent: _parseNullableDouble(json['sale_percent']),
      attributes: json['attributes'] as Map<String, dynamic>?,
      stockType: json['stock_type']?.toString(),
      groupedProducts: (json['grouped_products'] as List?)
          ?.map((e) => GroupedProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Trả về % giảm giá: ưu tiên sale_percent từ API, nếu null thì tự tính
  int? get displaySalePercent {
    if (salePercent != null) return salePercent!.round();
    if (originalPrice != null && originalPrice! > price && originalPrice! > 0) {
      return (((originalPrice! - price) / originalPrice!) * 100).round();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'sku': sku,
      'short_description': shortDescription,
      'primary_image_url': imageUrl,
      'price_jpy': price.toString(),
      'original_price_jpy': originalPrice?.toString(),
      'price_vnd': priceVnd?.toString(),
      'original_price_vnd': originalPriceVnd?.toString(),
      'points': points,
      'gender': gender,
      'movement_type': movementType,
      'condition': condition,
      'stock_quantity': stockQuantity,
      'is_featured': isFeatured,
      'average_rating': averageRating?.toString(),
      'review_count': reviewCount,
      'sold_count': soldCount,
      'brand': brandName != null
          ? {'name': brandName, 'slug': brandSlug}
          : null,
      'category': categoryName != null
          ? {'name': categoryName, 'slug': categorySlug}
          : null,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class ProductImage {
  final int id;
  final String imageUrl;
  final bool isPrimary;
  final int sortOrder;
  final String fileType;

  const ProductImage({
    required this.id,
    required this.imageUrl,
    this.isPrimary = false,
    this.sortOrder = 0,
    this.fileType = 'image',
  });

  bool get isVideo {
    if (fileType == 'video') return true;
    final url = imageUrl.toLowerCase();
    return url.contains('.mp4') || url.contains('.mov') || url.contains('.webm');
  }

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      imageUrl: json['image_url']?.toString() ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      fileType: json['file_type']?.toString() ?? 'image',
    );
  }
}

class GroupedProduct {
  final int id;
  final String name;
  final String? slug;
  final String? sku;
  final String imageUrl;
  final double price;
  final String? color;

  const GroupedProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.slug,
    this.sku,
    this.color,
  });

  factory GroupedProduct.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] as Map<String, dynamic>?;
    return GroupedProduct(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      sku: json['sku']?.toString(),
      imageUrl: json['primary_image_url']?.toString() ?? '',
      price: ProductModel._parseDouble(json['price_jpy'] ?? json['price']),
      color: attrs?['color']?.toString(),
    );
  }

  ProductModel toProductModel() => ProductModel(
        id: id,
        name: name,
        slug: slug,
        sku: sku,
        imageUrl: imageUrl,
        price: price,
      );
}
