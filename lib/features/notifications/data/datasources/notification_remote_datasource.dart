import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDatasource {
  final ApiClient _apiClient;

  NotificationRemoteDatasource(this._apiClient);

  Future<NotificationListResponse> getNotices({
    int page = 1,
    int perPage = 15,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    debugPrint('[NotificationDS] GET ${Endpoints.notices} page=$page');
    final response = await _apiClient.get(
      Endpoints.notices,
      queryParameters: params,
    );

    final data = response.data['data'];
    final list = (data['notices'] as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>?;
    final currentPage = pagination?['current_page'] as int? ?? page;
    final lastPage = pagination?['last_page'] as int? ??
        (list.length < perPage ? page : page + 1);

    return NotificationListResponse(
      notices: list,
      currentPage: currentPage,
      lastPage: lastPage,
      hasMore: currentPage < lastPage,
    );
  }

  /// GET /shop/notices?is_read=0 — chỉ lấy tổng số chưa đọc từ pagination.total
  Future<int> getUnreadCount() async {
    debugPrint('[NotificationDS] GET ${Endpoints.notices}?is_read=0');
    final response = await _apiClient.get(
      Endpoints.notices,
      queryParameters: {'is_read': 0, 'per_page': 1},
    );
    final pagination =
        response.data['data']['pagination'] as Map<String, dynamic>?;
    return pagination?['total'] as int? ?? 0;
  }

  /// GET /shop/notices/{id} — lấy chi tiết + đánh dấu đã đọc phía server
  Future<NotificationModel> getNoticeDetail(String id) async {
    debugPrint('[NotificationDS] GET ${Endpoints.notices}/$id');
    final response = await _apiClient.get('${Endpoints.notices}/$id');
    return NotificationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}

class NotificationListResponse {
  final List<NotificationModel> notices;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  const NotificationListResponse({
    required this.notices,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });
}
