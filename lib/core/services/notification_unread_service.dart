import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/notifications/data/datasources/notification_remote_datasource.dart';

class NotificationUnreadService {
  NotificationUnreadService._();
  static final NotificationUnreadService _instance =
      NotificationUnreadService._();
  static NotificationUnreadService get instance => _instance;

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Gọi ở splash/login: fetch số thông báo chưa đọc
  static Future<void> prefetchUnreadCount() async {
    try {
      final ds = NotificationRemoteDatasource(ApiClient());
      final count = await ds.getUnreadCount();
      _instance.unreadCount.value = count;
      debugPrint('[NotifUnread] unread=$count');
    } catch (e) {
      debugPrint('[NotifUnread] prefetch error: $e');
    }
  }

  /// Giảm 1 khi đọc 1 thông báo
  void decrement() {
    if (unreadCount.value > 0) unreadCount.value--;
  }

  /// Reset về 0 khi user vào trang thông báo
  void clearAll() {
    unreadCount.value = 0;
  }
}