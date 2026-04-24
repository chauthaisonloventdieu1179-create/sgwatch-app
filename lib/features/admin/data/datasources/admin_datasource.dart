import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_blog_model.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_conversation_model.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_discount_code_model.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_inventory_model.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_order_model.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_product_model.dart';

// ── Endpoint constants (admin) ─────────────────────────────────────────────
const _kAdminOrders = '/admin/shop/orders';
const _kAdminInventoryHistories = '/admin/shop/inventory-histories';
const _kAdminNotices = '/admin/notices';
const _kAdminProducts = '/admin/shop/products';
const _kAdminBrands = '/admin/shop-brands';
const _kAdminCategories = '/admin/shop-categories';
const _kAdminDiscountCodes = '/admin/discount-codes';
const _kAdminPosts = '/admin/posts';
const _kChatConversations = '/chat/conversations';
const _kChatHistoryList = '/chat/history/list';
const _kChatMarkAsRead = '/chat/messages/mark-as-read';
const _kChatSendMessage = '/chat/message';

// ── Response wrappers ──────────────────────────────────────────────────────

class AdminOrderListResponse {
  final List<AdminOrderModel> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  const AdminOrderListResponse({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class AdminInventoryListResponse {
  final List<AdminInventoryModel> records;
  final int currentPage;
  final int lastPage;
  final int total;

  const AdminInventoryListResponse({
    required this.records,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class AdminConversationListResponse {
  final List<AdminConversationModel> conversations;
  final int totalUnreadCount;
  final int currentPage;
  final int totalPages;

  const AdminConversationListResponse({
    required this.conversations,
    required this.totalUnreadCount,
    required this.currentPage,
    required this.totalPages,
  });
}

class AdminProductListResponse {
  final List<AdminProductModel> products;
  final int currentPage;
  final int lastPage;
  final int total;

  const AdminProductListResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

// ── Datasource ─────────────────────────────────────────────────────────────

class AdminDatasource {
  final ApiClient _api;

  AdminDatasource(this._api);

  // ── Orders ───────────────────────────────────────────────────────────────

  Future<AdminOrderListResponse> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (status != null) params['status'] = status;

    final resp = await _api.get(_kAdminOrders, queryParameters: params);
    final data = resp.data['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return AdminOrderListResponse(
      orders: (data['orders'] as List? ?? [])
          .map((e) => AdminOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      total: pagination['total'] as int? ?? 0,
    );
  }

  Future<AdminOrderModel> getOrderDetail(int orderId) async {
    final resp = await _api.get('$_kAdminOrders/$orderId');
    final data = resp.data['data']['order'] as Map<String, dynamic>;
    return AdminOrderModel.fromJson(data);
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await _api.put(
      '$_kAdminOrders/$orderId/status',
      data: {'status': status},
    );
  }

  Future<void> updateOrderPaymentStatus(
      int orderId, String paymentStatus) async {
    await _api.put(
      '$_kAdminOrders/$orderId/payment-status',
      data: {'payment_status': paymentStatus},
    );
  }

  // ── Inventory ────────────────────────────────────────────────────────────

  Future<AdminInventoryListResponse> getInventoryHistories({
    required String date,
    required String type,
    int page = 1,
    int perPage = 20,
  }) async {
    final resp = await _api.get(_kAdminInventoryHistories, queryParameters: {
      'date': date,
      'type': type,
      'page': page,
      'per_page': perPage,
    });
    final data = resp.data['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return AdminInventoryListResponse(
      records: (data['records'] as List? ?? [])
          .map((e) => AdminInventoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      total: pagination['total'] as int? ?? 0,
    );
  }

  // ── Notices ──────────────────────────────────────────────────────────────

  Future<void> createNotice({
    required String title,
    required String content,
    File? image,
  }) async {
    final map = <String, dynamic>{'title': title, 'content': content};
    if (image != null) {
      map['image'] = await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last);
    }
    await _api.post(_kAdminNotices, data: FormData.fromMap(map));
  }

  // ── Products ─────────────────────────────────────────────────────────────

  Future<AdminProductListResponse> getProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    int? brandId,
    String? keyword,
    String? stockType,
    String? gender,
    String? movementType,
    bool? isNew,
    bool? isDomestic,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (categoryId != null) params['category_id'] = categoryId;
    if (brandId != null) params['brand_id'] = brandId;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
    if (stockType != null) params['stock_type'] = stockType;
    if (gender != null) params['gender'] = gender;
    if (movementType != null) params['movement_type'] = movementType;
    if (isNew != null) params['is_new'] = isNew ? 1 : 0;
    if (isDomestic != null) params['is_domestic'] = isDomestic ? 1 : 0;

    final resp = await _api.get(_kAdminProducts, queryParameters: params);
    final data = resp.data['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return AdminProductListResponse(
      products: (data['products'] as List? ?? [])
          .map((e) => AdminProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      total: pagination['total'] as int? ?? 0,
    );
  }

  Future<AdminProductModel> getProductDetail(int productId) async {
    final resp = await _api.get('$_kAdminProducts/$productId');
    final data = resp.data['data']['product'] as Map<String, dynamic>? ??
        resp.data['data'] as Map<String, dynamic>;
    return AdminProductModel.fromJson(data);
  }

  Future<AdminProductModel> createProduct(FormData formData) async {
    final resp = await _api.post(_kAdminProducts, data: formData);
    final data = resp.data['data']['product'] as Map<String, dynamic>? ??
        resp.data['data'] as Map<String, dynamic>;
    return AdminProductModel.fromJson(data);
  }

  Future<AdminProductModel> updateProduct(
      int productId, FormData formData) async {
    final resp =
        await _api.post('$_kAdminProducts/$productId', data: formData);
    final data = resp.data['data']['product'] as Map<String, dynamic>? ??
        resp.data['data'] as Map<String, dynamic>;
    return AdminProductModel.fromJson(data);
  }

  Future<void> deleteProduct(int productId) async {
    await _api.delete('$_kAdminProducts/$productId');
  }

  Future<List<AdminBrandModel>> getBrands() async {
    final resp = await _api
        .get(_kAdminBrands, queryParameters: {'per_page': 100});
    final data = resp.data['data'] as Map<String, dynamic>;
    final list = data['brands'] as List? ?? data['data'] as List? ?? [];
    return list
        .map((e) => AdminBrandModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminCategoryModel>> getCategories() async {
    final resp = await _api
        .get(_kAdminCategories, queryParameters: {'per_page': 100});
    final data = resp.data['data'] as Map<String, dynamic>;
    final list = data['categories'] as List? ?? data['data'] as List? ?? [];
    return list
        .map((e) => AdminCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Discount Codes ───────────────────────────────────────────────────────

  Future<List<DiscountCodeModel>> getDiscountCodes({
    int page = 1,
    int perPage = 50,
  }) async {
    final resp = await _api.get(_kAdminDiscountCodes,
        queryParameters: {'page': page, 'per_page': perPage});
    final data = resp.data['data'] as Map<String, dynamic>;
    final list = data['discount_codes'] as List? ?? [];
    return list
        .map((e) => DiscountCodeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DiscountCodeModel> createDiscountCode({
    required String code,
    required int quantity,
    required int amount,
    required String expiresAt,
  }) async {
    final resp = await _api.post(_kAdminDiscountCodes, data: {
      'code': code,
      'quantity': quantity,
      'amount': amount,
      'expires_at': expiresAt,
    });
    return DiscountCodeModel.fromJson(
        resp.data['data']['discount_code'] as Map<String, dynamic>);
  }

  Future<DiscountCodeModel> updateDiscountCode({
    required int id,
    required String code,
    required int quantity,
    required int amount,
    required String expiresAt,
  }) async {
    final resp = await _api.post('$_kAdminDiscountCodes/$id', data: {
      'code': code,
      'quantity': quantity,
      'amount': amount,
      'expires_at': expiresAt,
    });
    return DiscountCodeModel.fromJson(
        resp.data['data']['discount_code'] as Map<String, dynamic>);
  }

  Future<void> deleteDiscountCode(int id) async {
    await _api.delete('$_kAdminDiscountCodes/$id');
  }

  // ── Blog Posts ───────────────────────────────────────────────────────────

  Future<List<AdminBlogPostModel>> getPosts({
    int page = 1,
    int perPage = 20,
    String? keyword,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
    final resp = await _api.get(_kAdminPosts, queryParameters: params);
    final data = resp.data['data'] as Map<String, dynamic>;
    final list = data['posts'] as List? ?? [];
    return list
        .map((e) => AdminBlogPostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminBlogPostModel> createPost(FormData formData) async {
    final resp = await _api.post(_kAdminPosts, data: formData);
    final data = resp.data['data']['post'] as Map<String, dynamic>;
    return AdminBlogPostModel.fromJson(data);
  }

  Future<AdminBlogPostModel> updatePost(int id, FormData formData) async {
    final resp = await _api.post('$_kAdminPosts/$id', data: formData);
    final data = resp.data['data']['post'] as Map<String, dynamic>;
    return AdminBlogPostModel.fromJson(data);
  }

  Future<void> deletePost(int id) async {
    await _api.delete('$_kAdminPosts/$id');
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  Future<AdminConversationListResponse> getConversations({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'is_hidden': false,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    final resp = await _api.get(_kChatConversations, queryParameters: params);
    final data = resp.data['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return AdminConversationListResponse(
      conversations: (data['conversations'] as List? ?? [])
          .map((e) =>
              AdminConversationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUnreadCount:
          pagination['total_unread_count'] as int? ?? 0,
      currentPage: pagination['current_page'] as int? ?? page,
      totalPages: pagination['total_pages'] as int? ?? 1,
    );
  }

  /// Lightweight call (limit=1, page=1) to get total_unread_count for badge.
  Future<int> getUnreadCount() async {
    try {
      final resp = await _api.get(_kChatConversations, queryParameters: {
        'is_hidden': false,
        'limit': 1,
        'page': 1,
      });
      final pagination =
          resp.data['data']['pagination'] as Map<String, dynamic>? ?? {};
      return pagination['total_unread_count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(int chatPartnerId) async {
    await _api.post(_kChatMarkAsRead,
        data: {'chat_partner_id': chatPartnerId});
  }

  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    String? message,
    File? file,
  }) async {
    final map = <String, dynamic>{'receiver_id': receiverId};
    if (message != null && message.isNotEmpty) map['message'] = message;
    if (file != null) {
      map['file'] = await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last);
    }
    final resp = await _api.post(_kChatSendMessage,
        data: FormData.fromMap(map));
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getChatHistory({
    required int receiverId,
    int limit = 50,
    int page = 1,
  }) async {
    final resp = await _api.get(_kChatHistoryList, queryParameters: {
      'receiver_id': receiverId,
      'limit': limit,
      'page': page,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }
}
