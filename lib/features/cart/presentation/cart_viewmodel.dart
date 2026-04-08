import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/app/app.dart';
import 'package:sgwatch_app/features/auth/presentation/login_screen.dart';
import 'package:sgwatch_app/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:sgwatch_app/features/cart/data/models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  static final CartViewModel _instance = CartViewModel._internal();
  factory CartViewModel() => _instance;
  CartViewModel._internal();

  final _datasource = CartRemoteDatasource(ApiClient());

  final List<CartItemModel> _items = [];
  bool _isLoading = false;
  bool _isAdding = false;

  String? _error;
  int _totalItems = 0;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  String? get error => _error;
  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);
  double get totalPrice => _items.fold(0.0, (sum, i) => sum + i.totalPrice);
  bool get isEmpty => _items.isEmpty;

  /// Số lượng sản phẩm trong giỏ (từ API total_items).
  int get totalItems => _totalItems;

  /// Clear in-memory cache (called on logout).
  void clearCache() {
    _items.clear();
    _totalItems = 0;

    notifyListeners();
  }

  /// Pre-fetch cart data (gọi từ SplashScreen khi có token).
  static Future<void> prefetchCart() async {
    try {
      final response = await _instance._datasource.getCart();
      _instance._items.clear();
      _instance._items.addAll(response.items);
      _instance._totalItems = response.totalItems;

    } catch (_) {}
  }

  /// GET /shop/cart/ - load giỏ hàng (always calls API)
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _datasource.getCart();
      _items.clear();
      _items.addAll(response.items);
      _totalItems = response.totalItems;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải giỏ hàng.';
      notifyListeners();
    }
  }

  /// Reload giỏ hàng không hiển thị loading (dùng sau add/remove).
  Future<void> _reloadCartSilently() async {
    try {
      final response = await _datasource.getCart();
      _items.clear();
      _items.addAll(response.items);
      _totalItems = response.totalItems;
    } catch (_) {}
  }

  /// POST /shop/cart/items - thêm sản phẩm vào giỏ
  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    debugPrint('[CartVM] addToCart called — productId=$productId, quantity=$quantity');
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[CartVM] token is NULL — redirect to login');
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return false;
    }
    _isAdding = true;
    notifyListeners();

    try {
      await _datasource.addToCart(productId, quantity: quantity);
      debugPrint('[CartVM] addToCart SUCCESS');
      // Reload cart to get fresh totalItems for badge
      await _reloadCartSilently();
      _isAdding = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[CartVM] addToCart FAILED — $e');
      if (e is DioException) {
        debugPrint('[CartVM] status=${e.response?.statusCode}');
        debugPrint('[CartVM] responseData=${e.response?.data}');
        debugPrint('[CartVM] requestUrl=${e.requestOptions.uri}');
        debugPrint('[CartVM] requestData=${e.requestOptions.data}');
      }
      _isAdding = false;
      notifyListeners();
      return false;
    }
  }

  /// PUT /shop/cart/items/{id} - tăng số lượng
  Future<void> incrementQuantity(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final oldQuantity = item.quantity;
    final newQuantity = oldQuantity + 1;

    // Optimistic update
    _items[index] = item.copyWith(quantity: newQuantity);
    notifyListeners();

    try {
      await _datasource.updateQuantity(item.id, newQuantity);
    } catch (e) {
      // Revert on error
      _items[index] = item.copyWith(quantity: oldQuantity);
      notifyListeners();
    }
  }

  /// PUT /shop/cart/items/{id} - giảm số lượng (tối thiểu 1)
  Future<void> decrementQuantity(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    if (item.quantity <= 1) return;

    final oldQuantity = item.quantity;
    final newQuantity = oldQuantity - 1;

    // Optimistic update
    _items[index] = item.copyWith(quantity: newQuantity);
    notifyListeners();

    try {
      await _datasource.updateQuantity(item.id, newQuantity);
    } catch (e) {
      // Revert on error
      _items[index] = item.copyWith(quantity: oldQuantity);
      notifyListeners();
    }
  }

  /// DELETE /shop/cart/items/{id} - xóa sản phẩm khỏi giỏ
  Future<void> removeItem(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final oldTotalItems = _totalItems;

    // Optimistic update
    _items.removeAt(index);
    _totalItems = (_totalItems - 1).clamp(0, oldTotalItems);
    notifyListeners();

    try {
      await _datasource.removeItem(item.id);
    } catch (e) {
      // Revert on error
      _items.insert(index, item);
      _totalItems = oldTotalItems;
      notifyListeners();
    }
  }
}
