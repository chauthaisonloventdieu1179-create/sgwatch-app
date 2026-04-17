import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/datasources/product_remote_datasource.dart';
import 'package:sgwatch_app/features/home/data/models/banner_model.dart';
import 'package:sgwatch_app/features/home/data/models/brand_model.dart';
import 'package:sgwatch_app/features/home/data/models/category_model.dart';
import 'package:sgwatch_app/features/home/data/models/collection_model.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class HomeViewModel extends ChangeNotifier {
  /// Cached data — loaded once at splash, shared across screens.
  static List<ProductModel> _cachedFeatured = [];
  static List<BannerModel> _cachedBanners = [];
  static List<BrandModel> _cachedBrands = [];
  static List<ProductModel> _cachedLaptops = [];
  static List<ProductModel> _cachedMacbooks = [];
  static List<ProductModel> _cachedIpads = [];
  static List<CollectionModel> _cachedCollections = [];

  static bool get hasCachedFeatured => _cachedFeatured.isNotEmpty;
  static bool get hasCachedBanners => _cachedBanners.isNotEmpty;
  static List<BannerModel> get cachedBanners => _cachedBanners;

  /// Brands (excluding special items) for filter bottom sheet.
  static List<BrandModel> get cachedFilterBrands {
    final brands = _cachedBrands.isNotEmpty ? _cachedBrands : _fallbackBrands;
    return brands.where((b) => b.id > 0).toList();
  }

  /// Row 1: watch brands + special watch filters
  static const _fallbackBrandsRow1 = [
    BrandModel(id: 1, name: 'Orient Star', slug: 'Orient Star'),
    BrandModel(id: 2, name: 'Orient', slug: 'Orient'),
    BrandModel(id: 3, name: 'Citizen', slug: 'Citizen 1'),
    BrandModel(id: 4, name: 'Seiko', slug: 'Seiko 1'),
    BrandModel(id: 5, name: 'Carnival', slug: 'Carnival'),
    BrandModel(id: 6, name: 'Longines', slug: 'Longines'),
    BrandModel(id: 7, name: 'Tissot', slug: 'Tissot 1'),
    // BrandModel(id: 8, name: 'Omega', slug: 'Omega'),
    BrandModel(id: 11, name: 'Đồng hồ khác', slug: 'dong-ho-khac'),
    BrandModel(id: -10, name: 'Đồng hồ nữ', slug: 'dong-ho-nu', filterGender: 'female'),
    BrandModel(id: -11, name: 'Đồng hồ cặp đôi', slug: 'dong-ho-cap-doi', filterGender: 'couple'),
    BrandModel(id: -12, name: 'Đồng hồ order', slug: 'dong-ho-order', filterStockType: 'pre_order'),
    BrandModel(id: -13, name: 'Đồng hồ nội địa Nhật', slug: 'dong-ho-noi-dia', filterIsDomestic: 1),
  ];

  /// Row 2: laptop, macbook, ipad, đồng hồ cũ
  static const _fallbackBrandsRow2 = [
    BrandModel(id: -20, name: 'Laptop', slug: 'laptop', filterCategoryId: 2),
    BrandModel(id: -21, name: 'Macbook', slug: 'macbook', filterCategoryId: 3),
    BrandModel(id: -22, name: 'iPad', slug: 'ipad', filterCategoryId: 4),
    BrandModel(id: -23, name: 'Đồng hồ cũ', slug: 'dong-ho-cu', filterCategoryId: 1, filterIsNew: 0),
  ];

  static const _fallbackBrands = [
    ..._fallbackBrandsRow1,
    ..._fallbackBrandsRow2,
  ];

  /// Called from SplashScreen to pre-fetch data (no token needed).
  static Future<void> prefetchHomeData() async {
    final datasource = ProductRemoteDatasource(ApiClient());
    await Future.wait([
      _fetchFeatured(datasource),
      _fetchBanners(datasource),
      _fetchBrands(datasource),
      _fetchCategoryProducts(datasource, 2, _cachedLaptops, (v) => _cachedLaptops = v),
      _fetchCategoryProducts(datasource, 3, _cachedMacbooks, (v) => _cachedMacbooks = v),
      _fetchCategoryProducts(datasource, 4, _cachedIpads, (v) => _cachedIpads = v),
      _fetchCollections(datasource),
    ]);
  }

  static Future<void> _fetchCollections(ProductRemoteDatasource ds) async {
    try {
      _cachedCollections = await ds.getCollections();
    } catch (_) {}
  }

  static Future<void> _fetchFeatured(ProductRemoteDatasource ds) async {
    try {
      _cachedFeatured = await ds.getFeaturedProducts();
    } catch (_) {}
  }

  static Future<void> _fetchBanners(ProductRemoteDatasource ds) async {
    try {
      _cachedBanners = await ds.getBanners();
    } catch (_) {}
  }

  static Future<void> _fetchCategoryProducts(
    ProductRemoteDatasource ds,
    int categoryId,
    List<ProductModel> current,
    void Function(List<ProductModel>) setter,
  ) async {
    try {
      final result = await ds.getProducts(categoryId: categoryId, perPage: 8);
      setter(result.products);
    } catch (_) {}
  }

  static Future<void> _fetchBrands(ProductRemoteDatasource ds) async {
    try {
      final brands = await ds.getBrands();
      // Append special items (watch filters + row 2)
      _cachedBrands = [
        ...brands,
        ..._fallbackBrandsRow1.where((b) => b.id < 0),
        ..._fallbackBrandsRow2,
      ];
    } catch (_) {}
  }

  bool _isLoading = false;
  String? _error;

  List<BannerModel> _banners = [];
  List<BrandModel> _brands = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _featured = [];
  List<ProductModel> _laptops = [];
  List<ProductModel> _macbooks = [];
  List<ProductModel> _ipads = [];
  List<CollectionModel> _collections = [];
  int _currentBannerIndex = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BannerModel> get banners => _banners;
  List<BrandModel> get brands => _brands;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get featuredProducts => _featured;
  List<ProductModel> get laptops => _laptops;
  List<ProductModel> get macbooks => _macbooks;
  List<ProductModel> get ipads => _ipads;
  List<CollectionModel> get collections => _collections;

  int get currentBannerIndex => _currentBannerIndex;

  int get cartItemCount => CartViewModel().totalItems;

  void setBannerIndex(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  Future<void> loadHomeData() async {
    // Nếu đã có cache từ splash → dùng ngay, không show loading
    if (_cachedFeatured.isNotEmpty || _cachedBanners.isNotEmpty) {
      _featured = _cachedFeatured;
      _banners = _cachedBanners;
      _brands = _cachedBrands.isNotEmpty ? _cachedBrands : _getFallbackBrands();
      _categories = _getMockCategories();
      _laptops = _cachedLaptops;
      _macbooks = _cachedMacbooks;
      _ipads = _cachedIpads;
      _collections = _cachedCollections;
      _isLoading = false;
      _error = null;
      notifyListeners();

      // Background refresh all data
      _backgroundRefreshAll();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final datasource = ProductRemoteDatasource(ApiClient());

      final results = await Future.wait([
        datasource.getFeaturedProducts(),
        datasource.getBanners(),
        datasource.getBrands(),
      ]);

      _featured = results[0] as List<ProductModel>;
      _cachedFeatured = _featured;
      _banners = results[1] as List<BannerModel>;
      _cachedBanners = _banners;

      final brands = results[2] as List<BrandModel>;
      _brands = [
        ...brands,
        ..._fallbackBrandsRow1.where((b) => b.id < 0),
        ..._fallbackBrandsRow2,
      ];
      _cachedBrands = _brands;

      _categories = _getMockCategories();

      // Fetch laptop/macbook/ipad in parallel
      final catResults = await Future.wait([
        datasource.getProducts(categoryId: 2, perPage: 8),
        datasource.getProducts(categoryId: 3, perPage: 8),
        datasource.getProducts(categoryId: 4, perPage: 8),
      ]);
      _laptops = catResults[0].products;
      _cachedLaptops = _laptops;
      _macbooks = catResults[1].products;
      _cachedMacbooks = _macbooks;
      _ipads = catResults[2].products;
      _cachedIpads = _ipads;

      try {
        _collections = await datasource.getCollections();
        _cachedCollections = _collections;
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải dữ liệu. Vui lòng thử lại.';
      notifyListeners();
    }
  }

  /// Background refresh all home data, only notify if data changed.
  Future<void> _backgroundRefreshAll() async {
    final datasource = ProductRemoteDatasource(ApiClient());
    await Future.wait([
      _refreshBanners(datasource),
      _refreshFeatured(datasource),
      _refreshCategory(datasource, 2, () => _laptops, (v) { _laptops = v; _cachedLaptops = v; }),
      _refreshCategory(datasource, 3, () => _macbooks, (v) { _macbooks = v; _cachedMacbooks = v; }),
      _refreshCategory(datasource, 4, () => _ipads, (v) { _ipads = v; _cachedIpads = v; }),
      _refreshCollections(datasource),
    ]);
  }

  Future<void> _refreshCollections(ProductRemoteDatasource ds) async {
    try {
      final fresh = await ds.getCollections();
      _collections = fresh;
      _cachedCollections = fresh;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _refreshBanners(ProductRemoteDatasource ds) async {
    try {
      final fresh = await ds.getBanners();
      if (!_sameBanners(_banners, fresh)) {
        _banners = fresh;
        _cachedBanners = fresh;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _refreshFeatured(ProductRemoteDatasource ds) async {
    try {
      final fresh = await ds.getFeaturedProducts();
      if (!_sameProducts(_featured, fresh)) {
        _featured = fresh;
        _cachedFeatured = fresh;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _refreshCategory(
    ProductRemoteDatasource ds,
    int categoryId,
    List<ProductModel> Function() getter,
    void Function(List<ProductModel>) setter,
  ) async {
    try {
      final result = await ds.getProducts(categoryId: categoryId, perPage: 8);
      if (!_sameProducts(getter(), result.products)) {
        setter(result.products);
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Compare two product lists by id + price + name.
  static bool _sameProducts(List<ProductModel> a, List<ProductModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].price != b[i].price || a[i].name != b[i].name) {
        return false;
      }
    }
    return true;
  }

  /// Compare two banner lists by id + imageUrl.
  static bool _sameBanners(List<BannerModel> a, List<BannerModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].imageUrl != b[i].imageUrl) {
        return false;
      }
    }
    return true;
  }

  /// Force refresh featured products from API.
  Future<void> refreshFeaturedProducts() async {
    try {
      final datasource = ProductRemoteDatasource(ApiClient());
      _featured = await datasource.getFeaturedProducts();
      _cachedFeatured = _featured;
      notifyListeners();
    } catch (_) {}
  }

  /// Force refresh banners from API (called when returning to home).
  Future<void> refreshBanners() async {
    try {
      final datasource = ProductRemoteDatasource(ApiClient());
      final fresh = await datasource.getBanners();
      _banners = fresh;
      _cachedBanners = fresh;
      notifyListeners();
    } catch (_) {}
  }

  // ── Fallback / Mock data ────────────────────────────────────

  /// Fallback brand list if API fails (same order as API JSON)
  List<BrandModel> _getFallbackBrands() => _fallbackBrands;

  List<CategoryModel> _getMockCategories() {
    return const [
      CategoryModel(id: 1, name: 'Đồng hồ', slug: 'dong-ho'),
      CategoryModel(id: 2, name: 'Laptop', slug: 'laptop'),
      CategoryModel(id: 3, name: 'Macbook', slug: 'macbook'),
      CategoryModel(id: 4, name: 'iPad', slug: 'ipad'),
    ];
  }

}
