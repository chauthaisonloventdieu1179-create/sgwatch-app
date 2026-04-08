import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/cart/data/models/cart_item_model.dart';

class CartRemoteDatasource {
  final ApiClient _apiClient;

  CartRemoteDatasource(this._apiClient);

  /// GET /shop/cart/
  Future<CartResponse> getCart() async {
    final response = await _apiClient.get(Endpoints.cart);
    final cart = response.data['data']['cart'] as Map<String, dynamic>;
    final items = (cart['items'] as List)
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CartResponse(
      items: items,
      totalItems: cart['total_items'] as int? ?? items.length,
      totalJpy: _parseDouble(cart['total_jpy']),
      totalVnd: _parseDouble(cart['total_vnd']),
    );
  }

  /// POST /shop/cart/items
  Future<CartItemModel> addToCart(int productId, {int quantity = 1}) async {
    final response = await _apiClient.post(
      Endpoints.addToCart,
      data: {
        'product_id': productId,
        'quantity': quantity,
      },
    );
    final cartItem = response.data['data']['cart_item'] as Map<String, dynamic>;
    return CartItemModel.fromJson(cartItem);
  }

  /// PUT /shop/cart/items/{id}
  Future<CartItemModel> updateQuantity(int cartItemId, int quantity) async {
    final response = await _apiClient.put(
      '${Endpoints.addToCart}/$cartItemId',
      data: {'quantity': quantity},
    );
    final cartItem = response.data['data']['cart_item'] as Map<String, dynamic>;
    return CartItemModel.fromJson(cartItem);
  }

  /// DELETE /shop/cart/items/{id}
  Future<void> removeItem(int cartItemId) async {
    await _apiClient.delete('${Endpoints.addToCart}/$cartItemId');
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class CartResponse {
  final List<CartItemModel> items;
  final int totalItems;
  final double totalJpy;
  final double totalVnd;

  const CartResponse({
    required this.items,
    required this.totalItems,
    required this.totalJpy,
    required this.totalVnd,
  });
}
