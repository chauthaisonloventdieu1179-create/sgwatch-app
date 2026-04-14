import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/home/data/models/banner_model.dart';
import 'package:sgwatch_app/features/home/data/models/collection_model.dart';
import 'package:sgwatch_app/features/home/data/models/brand_model.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/data/models/post_model.dart';
import 'package:sgwatch_app/features/home/data/models/review_model.dart';

class ProductRemoteDatasource {
  final ApiClient _apiClient;

  ProductRemoteDatasource(this._apiClient);

  /// GET /banners (no token required)
  Future<List<BannerModel>> getBanners() async {
    final response = await _apiClient.get(Endpoints.banners);
    final list = response.data['data']['banners'] as List;
    return list
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /shop/collections
  Future<List<CollectionModel>> getCollections() async {
    final response = await _apiClient.get(Endpoints.collections);
    final list = response.data['data']['collections'] as List;
    return list
        .map((e) => CollectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /posts (no token required)
  Future<List<PostModel>> getPosts() async {
    final response = await _apiClient.get(Endpoints.posts);
    final list = response.data['data']['posts'] as List;
    return list
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /shop/featured-products (no token required)
  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await _apiClient.get(Endpoints.featuredProducts);
    final list = response.data['data']['products'] as List;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /shop/brands (no token required)
  Future<List<BrandModel>> getBrands() async {
    final response = await _apiClient.get(Endpoints.shopBrands);
    final list = response.data['data']['brands'] as List;
    return list
        .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /shop/products (with filters + pagination)
  Future<ProductListResponse> getProducts({
    String? keyword,
    int? brandId,
    int? categoryId,
    String? categorySlug,
    String? gender,
    String? movementType,
    String? sortBy,
    String? stockType,
    int? isDomestic,
    int? isNew,
    String? groupBy,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
    if (brandId != null) params['brand_id'] = brandId;
    if (categoryId != null) params['category_id'] = categoryId;
    if (categorySlug != null && categorySlug.isNotEmpty) {
      params['category_slug'] = categorySlug;
    }
    if (gender != null && gender.isNotEmpty) params['gender'] = gender;
    if (movementType != null && movementType.isNotEmpty) {
      params['movement_type'] = movementType;
    }
    if (sortBy != null && sortBy.isNotEmpty) params['sort_by'] = sortBy;
    if (stockType != null && stockType.isNotEmpty) {
      params['stock_type'] = stockType;
    }
    if (isDomestic != null) params['is_domestic'] = isDomestic;
    if (isNew != null) params['is_new'] = isNew;
    if (groupBy != null && groupBy.isNotEmpty) params['group_by'] = groupBy;

    debugPrint('[Datasource] GET ${Endpoints.shopProducts} params=$params');
    final response = await _apiClient.get(
      Endpoints.shopProducts,
      queryParameters: params,
    );
    final data = response.data['data'];
    debugPrint('[Datasource] response: ${response.data}');
    final list = (data['products'] as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse pagination — handle various response shapes
    final pagination = data['pagination'] as Map<String, dynamic>?;
    final currentPage = pagination?['current_page'] as int? ?? page;
    final lastPage = pagination?['last_page'] as int? ??
        (list.length < perPage ? page : page + 1);

    return ProductListResponse(
      products: list,
      currentPage: currentPage,
      lastPage: lastPage,
      hasMore: currentPage < lastPage,
    );
  }

  /// GET /shop/products?keyword={name}&brand_id=5&group_by=name
  /// Dùng cho Carnival: lấy grouped_products (tất cả variants cùng tên)
  Future<List<GroupedProduct>?> getCarnivalGroupedProducts(
      String productName) async {
    final result = await getProducts(
      keyword: productName,
      brandId: 5,
      groupBy: 'name',
      perPage: 1,
    );
    if (result.products.isEmpty) return null;
    return result.products.first.groupedProducts;
  }

  /// GET /shop/products/{slug}
  Future<ProductModel> getProductDetail(String slug) async {
    final response = await _apiClient.get('${Endpoints.productDetail}/$slug');
    final product = response.data['data']['product'] as Map<String, dynamic>;
    return ProductModel.fromJson(product);
  }

  /// GET /shop/products/{id}/reviews
  Future<ReviewListResponse> getProductReviews(int productId,
      {int page = 1}) async {
    final response = await _apiClient.get(
      '${Endpoints.productReviews}/$productId/reviews',
      queryParameters: {'page': page},
    );
    final data = response.data['data'];
    final list = (data['reviews'] as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        ReviewPagination.fromJson(data['pagination'] as Map<String, dynamic>);
    return ReviewListResponse(reviews: list, pagination: pagination);
  }

  /// POST /shop/reviews (create)
  Future<bool> createReview({
    required int productId,
    required int rating,
    String? title,
    String? content,
    List<String>? imagePaths,
  }) async {
    final formData = FormData.fromMap({
      'product_id': productId,
      'rating': rating,
      if (title != null && title.isNotEmpty) 'title': title,
      if (content != null && content.isNotEmpty) 'comment': content,
    });
    if (imagePaths != null) {
      for (final path in imagePaths) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(path),
        ));
      }
    }
    await _apiClient.post(Endpoints.reviews, data: formData);
    return true;
  }

  /// POST /shop/reviews/{id} (update)
  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    String? title,
    String? content,
    List<String>? existingImages, // null = Case5, [] = Case3, [...] = Case1/2/4
    List<String>? newImagePaths,
  }) async {
    final formData = FormData.fromMap({
      'rating': rating,
      if (title != null && title.isNotEmpty) 'title': title,
      if (content != null && content.isNotEmpty) 'comment': content,
    });

    if (existingImages != null) {
      if (existingImages.isEmpty) {
        // Case 3: xóa hết ảnh — gửi field rỗng để server biết existing_images tồn tại
        formData.fields.add(const MapEntry('existing_images', ''));
      } else {
        // Case 1/2/4: giữ các ảnh được chỉ định (gửi relative path)
        for (final urlOrPath in existingImages) {
          formData.fields.add(MapEntry('existing_images[]', _toRelativePath(urlOrPath)));
        }
      }
    }
    // Case 5: existingImages == null → không gửi gì → ảnh không bị đụng

    // New images
    if (newImagePaths != null) {
      for (final path in newImagePaths) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(path),
        ));
      }
    }
    await _apiClient.post('${Endpoints.reviews}/$reviewId', data: formData);
    return true;
  }

  /// Chuyển full URL thành relative path để gửi lên API
  /// vd: "http://api.sgwatch.jp/storage/reviews/1/abc.jpg" → "reviews/1/abc.jpg"
  String _toRelativePath(String urlOrPath) {
    if (!urlOrPath.startsWith('http')) return urlOrPath;
    final idx = urlOrPath.indexOf('/storage/');
    return idx >= 0 ? urlOrPath.substring(idx + 9) : urlOrPath;
  }

  /// DELETE /shop/reviews/{id}
  Future<bool> deleteReview(int reviewId) async {
    await _apiClient.delete('${Endpoints.reviews}/$reviewId');
    return true;
  }
}

class ReviewListResponse {
  final List<ReviewModel> reviews;
  final ReviewPagination pagination;

  const ReviewListResponse({
    required this.reviews,
    required this.pagination,
  });
}

class ProductListResponse {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  const ProductListResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });
}
