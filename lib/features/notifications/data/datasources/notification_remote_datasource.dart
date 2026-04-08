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
