import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class FavoriteRemoteDatasource {
  final ApiClient _apiClient;

  FavoriteRemoteDatasource(this._apiClient);

  /// GET /shop/favorites
  Future<List<ProductModel>> getFavorites() async {
    final response = await _apiClient.get(Endpoints.favorites);
    final list = response.data['data']['favorites'] as List;
    return list.map((item) {
      final product = item['product'] as Map<String, dynamic>;
      return ProductModel.fromJson(product);
    }).toList();
  }

  /// POST /shop/favorites/toggle
  /// Returns true if product is now favorited, false if removed.
  Future<bool> toggleFavorite(int productId) async {
    final response = await _apiClient.post(
      Endpoints.favoritesToggle,
      data: {'product_id': productId.toString()},
    );
    return response.data['data']['is_favorited'] as bool;
  }
}
