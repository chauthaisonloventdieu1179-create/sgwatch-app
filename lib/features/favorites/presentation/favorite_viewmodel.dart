import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/favorites/data/datasources/favorite_remote_datasource.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class FavoriteViewModel extends ChangeNotifier {
  static final FavoriteViewModel _instance = FavoriteViewModel._internal();
  factory FavoriteViewModel() => _instance;
  FavoriteViewModel._internal()
      : _datasource = FavoriteRemoteDatasource(ApiClient());

  final FavoriteRemoteDatasource _datasource;

  final Map<int, ProductModel> _favorites = {};
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get favorites => _favorites.values.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorite(int productId) => _favorites.containsKey(productId);

  /// Load favorites from API
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _datasource.getFavorites();
      _favorites.clear();
      for (final product in list) {
        _favorites[product.id] = product;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Không thể tải danh sách yêu thích.');
      notifyListeners();
    }
  }

  /// Toggle favorite via API
  Future<void> toggle(ProductModel product) async {
    // Optimistic update
    final wasInFavorites = _favorites.containsKey(product.id);
    if (wasInFavorites) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }
    notifyListeners();

    try {
      final isFavorited = await _datasource.toggleFavorite(product.id);
      // Sync with server response
      if (isFavorited && !_favorites.containsKey(product.id)) {
        _favorites[product.id] = product;
        notifyListeners();
      } else if (!isFavorited && _favorites.containsKey(product.id)) {
        _favorites.remove(product.id);
        notifyListeners();
      }
    } catch (e) {
      // Revert on error
      if (wasInFavorites) {
        _favorites[product.id] = product;
      } else {
        _favorites.remove(product.id);
      }
      notifyListeners();
    }
  }

  String _extractError(Object e, String fallback) {
    if (e is DioException && e.response?.data is Map) {
      final data = e.response!.data as Map;
      final msg = data['message'] ?? data['data']?['message'];
      if (msg != null) return msg.toString();
    }
    return fallback;
  }
}
