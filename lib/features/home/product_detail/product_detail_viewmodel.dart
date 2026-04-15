import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/home/data/datasources/product_remote_datasource.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/data/models/review_model.dart';

class ProductDetailViewModel extends ChangeNotifier {
  ProductModel product;
  List<GroupedProduct>? _groupedProducts;

  ProductDetailViewModel(this.product, {List<GroupedProduct>? groupedProducts})
      : _groupedProducts = groupedProducts;

  final _datasource = ProductRemoteDatasource(ApiClient());

  bool _isLoading = false;
  String? _error;
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  List<String> _images = [];
  List<List<String>> _specs = [];
  String? _productInfo;
  String? _dealInfo;
  String? _description;

  // Reviews
  List<ReviewModel> _reviews = [];
  bool _isReviewsLoading = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentImageIndex => _currentImageIndex;
  bool get isDescriptionExpanded => _isDescriptionExpanded;
  List<String> get images => _images;
  List<List<String>> get visibleSpecs =>
      _isDescriptionExpanded ? _specs : _specs.take(6).toList();
  bool get hasMoreSpecs => _specs.length > 6;
  String? get productInfo => _productInfo;
  String? get dealInfo => _dealInfo;
  String? get description => _description;
  bool get isWatch => product.categorySlug == null || product.categorySlug == 'dong-ho';
  String? get shortDescription => isWatch ? null : product.shortDescription;
  List<GroupedProduct>? get groupedProducts => _groupedProducts;

  bool get _isCarnival =>
      product.brandName == 'Carnival' || product.brandSlug == 'Carnival';

  List<ReviewModel> get reviews => _reviews;
  bool get isReviewsLoading => _isReviewsLoading;
  bool get isPurchased => product.isPurchased == true;
  ReviewModel? get myReview {
    final idx = _reviews.indexWhere((r) => r.isOwner);
    return idx >= 0 ? _reviews[idx] : null;
  }

  void setImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void expandDescription() {
    _isDescriptionExpanded = true;
    notifyListeners();
  }

  void selectVariant(GroupedProduct v) {
    product = v.toProductModel();
    _images = v.imageUrl.isNotEmpty ? [v.imageUrl] : [product.imageUrl];
    _currentImageIndex = 0;
    _specs = _buildSpecsFromProduct(product);
    notifyListeners();
    loadProductDetail(silent: true);
  }

  Future<void> loadProductDetail({bool silent = false}) async {
    if (product.slug == null || product.slug!.isEmpty) {
      _images = [product.imageUrl];
      _specs = _buildSpecsFromProduct(product);
      notifyListeners();
      return;
    }

    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      // Build parallel calls: detail + reviews + (Carnival grouped if needed)
      final fetchCarnival = _groupedProducts == null && _isCarnival;
      final futures = <Future>[
        _datasource.getProductDetail(product.slug!),
        _datasource.getProductReviews(product.id),
        if (fetchCarnival)
          _datasource.getCarnivalGroupedProducts(product.name),
      ];
      final results = await Future.wait(futures);

      final detail = results[0] as ProductModel;
      final reviewResponse = results[1] as ReviewListResponse;
      if (fetchCarnival && results.length > 2) {
        _groupedProducts = results[2] as List<GroupedProduct>?;
      }

      product = detail;

      // Images from API: primary_image_url first, then images array (no duplicates)
      final seen = <String>{};
      final allImages = <String>[];
      if (detail.imageUrl.isNotEmpty) {
        seen.add(detail.imageUrl);
        allImages.add(detail.imageUrl);
      }
      if (detail.images != null) {
        for (final img in detail.images!) {
          if (seen.add(img.imageUrl)) {
            allImages.add(img.imageUrl);
          }
        }
      }
      _images = allImages.isNotEmpty ? allImages : [detail.imageUrl];

      _productInfo = detail.productInfo;
      _dealInfo = detail.dealInfo;
      _description = detail.description;
      _specs = _buildSpecsFromProduct(detail);
      _reviews = reviewResponse.reviews;

      if (!silent) _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _isLoading = false;
        _error = 'Không thể tải chi tiết sản phẩm.';
      }
      notifyListeners();
    }
  }

  /// Reload reviews only (after create/update/delete)
  Future<void> reloadReviews() async {
    _isReviewsLoading = true;
    notifyListeners();

    try {
      final response = await _datasource.getProductReviews(product.id);
      _reviews = response.reviews;
    } catch (_) {}

    _isReviewsLoading = false;
    notifyListeners();
  }

  /// Create review
  Future<bool> createReview({
    required int rating,
    String? title,
    String? content,
    List<String>? imagePaths,
  }) async {
    try {
      await _datasource.createReview(
        productId: product.id,
        rating: rating,
        title: title,
        content: content,
        imagePaths: imagePaths,
      );
      await reloadReviews();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update review
  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    String? title,
    String? content,
    List<String>? existingImages,
    List<String>? newImagePaths,
  }) async {
    try {
      await _datasource.updateReview(
        reviewId: reviewId,
        rating: rating,
        title: title,
        content: content,
        existingImages: existingImages,
        newImagePaths: newImagePaths,
      );
      await reloadReviews();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete review
  Future<bool> deleteReview(int reviewId) async {
    try {
      await _datasource.deleteReview(reviewId);
      await reloadReviews();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Attribute keys to skip (already shown above or duplicated)
  static const _skipAttributeKeys = {
    'brand', 'brand_name', 'category', 'category_name',
    'price', 'original_price', 'price_jpy', 'original_price_jpy',
    'price_vnd', 'original_price_vnd', 'sale_percent',
    'name', 'slug', 'sku', 'description', 'short_description',
    'product_info', 'deal_info', 'image', 'images', 'image_url',
    'gender', 'movement_type', 'condition',
    'stock_quantity', 'warranty', 'warranty_months',
    'points', 'is_featured', 'is_favorited', 'is_purchased',
    'average_rating', 'review_count', 'view_count', 'sold_count',
    'thong_so_ky_thuat', // parsed separately below
  };

  // Labels inside thong_so_ky_thuat that duplicate fixed rows above
  static const _thongSoSkipLabels = {
    'thương hiệu',
    'số hiệu sản phẩm',
    'mã sản phẩm',
    'giới tính',
  };

  List<List<String>> _buildSpecsFromProduct(ProductModel p) {
    final specs = <List<String>>[];
    if (p.sku != null) specs.add(['Mã sản phẩm', p.sku!]);

    // Brand: ưu tiên brandName, fallback sang attributes['brand']
    final brand = p.brandName
        ?? p.attributes?['brand']?.toString()
        ?? p.attributes?['brand_name']?.toString();
    if (brand != null && brand.isNotEmpty) {
      specs.add(['Thương hiệu', brand]);
    }

    if (p.gender != null) specs.add(['Giới tính', _mapGender(p.gender!)]);
    if (p.movementType != null) specs.add(['Kiểu máy', _mapMovement(p.movementType!)]);
    if (p.condition != null) specs.add(['Tình trạng', _mapCondition(p.condition!)]);
    if (p.warrantyMonths != null && p.warrantyMonths! > 0) {
      specs.add(['Bảo hành', '${p.warrantyMonths} tháng']);
    }

    if (p.attributes != null) {
      // Generic attributes (electronics: gpu, cpu, ram, etc.)
      for (final entry in p.attributes!.entries) {
        if (_skipAttributeKeys.contains(entry.key)) continue;
        final raw = entry.value;
        if (raw == null) continue;
        final String value;
        if (entry.key == 'battery') {
          final num? n = raw is num ? raw : num.tryParse(raw.toString());
          if (n != null && n <= 1) {
            value = '${(n * 100).round()}%';
          } else {
            value = raw.toString();
          }
        } else {
          value = raw.toString();
        }
        if (value.isEmpty) continue;
        specs.add([_mapAttributeKey(entry.key), value]);
      }

      // Parse thong_so_ky_thuat thành từng hàng label | value
      final thongSo = p.attributes!['thong_so_ky_thuat']?.toString();
      if (thongSo != null && thongSo.isNotEmpty) {
        _appendThongSoKyThuat(thongSo, specs);
      }
    }

    return specs;
  }

  void _appendThongSoKyThuat(String raw, List<List<String>> specs) {
    // Tách theo dòng trống (\r\n\r\n hoặc \n\n)
    final lines = raw.split(RegExp(r'\r?\n\r?\n'));
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final colonIdx = trimmed.indexOf(':');
      if (colonIdx < 0) continue;
      final label = trimmed.substring(0, colonIdx).trim();
      final value = trimmed.substring(colonIdx + 1).trim();
      if (label.isEmpty || value.isEmpty) continue;
      // Bỏ các dòng trùng với fixed rows đã hiển thị
      if (_thongSoSkipLabels.contains(label.toLowerCase())) continue;
      specs.add([label, value]);
    }
  }

  static const _attributeLabels = {
    'year': 'Năm sản xuất',
    'color': 'Màu sắc',
    'gpu': 'Card đồ họa',
    'ports': 'Cổng kết nối',
    'target_customer': 'Đối tượng',
    'battery': 'Pin',
    'design': 'Thiết kế',
    'security': 'Bảo mật',
    'screen': 'Màn hình',
    'cpu': 'CPU',
    'ram': 'RAM',
    'storage': 'Ổ cứng',
    'os': 'Hệ điều hành',
    'weight': 'Trọng lượng',
    'size': 'Kích thước',
  };

  String _mapAttributeKey(String key) {
    return _attributeLabels[key] ?? key;
  }

  String _mapGender(String value) {
    switch (value) {
      case 'male': return 'Nam';
      case 'female': return 'Nữ';
      case 'unisex': return 'Unisex';
      default: return value;
    }
  }

  String _mapMovement(String value) {
    switch (value) {
      case 'quartz': return 'Quartz (Pin)';
      case 'automatic': return 'Automatic (Cơ)';
      case 'mechanical': return 'Mechanical (Cơ)';
      case 'solar': return 'Solar (Năng lượng mặt trời)';
      case 'eco-drive': return 'Eco-drive';
      default: return value;
    }
  }

  String _mapCondition(String value) {
    switch (value) {
      case 'new': return 'Mới';
      case 'like_new': return 'Like new';
      case 'display': return 'Trưng bày';
      case 'used': return 'Đã qua sử dụng';
      default: return value;
    }
  }
}
