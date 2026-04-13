import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/home/data/datasources/product_remote_datasource.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class ProductListViewModel extends ChangeNotifier {
  final String? _initialCategorySlug;
  final int? _initialCategoryId;
  final int? isDomestic;
  final int? isNew;

  ProductListViewModel({
    String? categorySlug,
    int? categoryId,
    this.isDomestic,
    this.isNew,
    int? brandId,
    String? initialKeyword,
    String? initialGender,
    String? initialStockType,
    String sortBy = 'newest',
    String? groupBy,
  })  : _initialCategorySlug = categorySlug,
        _initialCategoryId = categoryId {
    _filterCategoryId = categoryId;
    _filterBrandId = brandId;
    _keyword = initialKeyword;
    _filterGender = initialGender;
    _filterStockType = initialStockType;
    _sortBy = sortBy;
    _groupBy = groupBy;
  }

  final _datasource = ProductRemoteDatasource(ApiClient());
  static const _perPage = 10;

  // ── State ──────────────────────────────────────────────────
  final List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  // ── Filters ────────────────────────────────────────────────
  String? _keyword;
  int? _filterCategoryId;
  int? _filterBrandId;
  String? _filterGender;
  String? _filterMovementType;
  String? _filterStockType;
  int? _filterIsNew;
  String _sortBy = 'newest';
  String? _groupBy;

  Timer? _debounce;

  // ── Getters ────────────────────────────────────────────────
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get sortBy => _sortBy;
  int? get filterCategoryId => _filterCategoryId;
  int? get filterBrandId => _filterBrandId;
  String? get filterGender => _filterGender;
  String? get filterMovementType => _filterMovementType;
  String? get filterStockType => _filterStockType;
  int? get filterIsNew => _filterIsNew;

  int get filterCount {
    int c = 0;
    if (_filterCategoryId != null) c++;
    if (_filterBrandId != null) c++;
    if (_filterGender != null) c++;
    if (_filterMovementType != null) c++;
    if (_filterStockType != null) c++;
    if (_filterIsNew != null) c++;
    return c;
  }

  // ── Load page 1 ───────────────────────────────────────────
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    _products.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _fetchPage(1);
      _products.addAll(response.products);
      _currentPage = response.currentPage;
      _hasMore = response.hasMore;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải danh sách sản phẩm.';
      notifyListeners();
    }
  }

  // ── Load next page ────────────────────────────────────────
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _fetchPage(nextPage);
      _products.addAll(response.products);
      _currentPage = response.currentPage;
      _hasMore = response.hasMore;
    } catch (_) {}

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Keyword search (debounced 500ms) ──────────────────────
  void setKeyword(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _keyword = trimmed.isEmpty ? null : trimmed;
      loadProducts();
    });
  }

  // ── Sort ───────────────────────────────────────────────────
  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) return;
    _sortBy = sortBy;
    loadProducts();
  }

  // ── Apply filter from bottom sheet ────────────────────────
  void applyFilter(Map<String, dynamic> result) {
    _filterCategoryId = result['category_id'] as int?;
    _filterBrandId = result['brand_id'] as int?;
    _filterGender = result['gender'] as String?;
    _filterMovementType = result['movement_type'] as String?;
    _filterStockType = result['stock_type'] as String?;
    _filterIsNew = result['is_new'] as int?;
    loadProducts();
  }

  // ── Clear all filters ─────────────────────────────────────
  void clearFilters() {
    _filterCategoryId = _initialCategoryId;
    _filterBrandId = null;
    _filterGender = null;
    _filterMovementType = null;
    _filterStockType = null;
    _filterIsNew = null;
    _keyword = null;
    _sortBy = 'newest';
    loadProducts();
  }

  // ── Private ────────────────────────────────────────────────
  Future<ProductListResponse> _fetchPage(int page) {
    return _datasource.getProducts(
      keyword: _keyword,
      brandId: _filterBrandId,
      categoryId: _filterCategoryId,
      categorySlug: _filterCategoryId != null ? null : _initialCategorySlug,
      gender: _filterGender,
      movementType: _filterMovementType,
      sortBy: _sortBy,
      stockType: _filterStockType,
      isDomestic: isDomestic,
      isNew: _filterIsNew ?? isNew,
      groupBy: _groupBy,
      page: page,
      perPage: _perPage,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
