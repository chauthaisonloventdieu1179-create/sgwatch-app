import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/orders/data/models/order_model.dart';

class OrderRemoteDatasource {
  final ApiClient _client;

  OrderRemoteDatasource(this._client);

  Future<List<OrderListItem>> getOrders(
    String status, {
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _client.get(
      Endpoints.orders,
      queryParameters: {
        'status': status,
        'page': page,
        'per_page': perPage,
      },
    );
    final list = response.data['data']['orders'] as List;
    return list
        .map((e) => OrderListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderDetailModel> getOrderDetail(int id) async {
    final response = await _client.get('${Endpoints.orders}/$id');
    final data = response.data['data']['order'] as Map<String, dynamic>;
    return OrderDetailModel.fromJson(data);
  }
}
