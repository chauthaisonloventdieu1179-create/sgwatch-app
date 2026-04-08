import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/big_sale/data/models/big_sale_model.dart';

class BigSaleRemoteDatasource {
  final ApiClient _apiClient;

  BigSaleRemoteDatasource(this._apiClient);

  /// GET /big-sales/{id}
  Future<BigSaleModel> getBigSale(int id) async {
    final response = await _apiClient.get('${Endpoints.bigSale}/$id');
    final data = response.data['data']['big_sale'] as Map<String, dynamic>;
    return BigSaleModel.fromJson(data);
  }
}
