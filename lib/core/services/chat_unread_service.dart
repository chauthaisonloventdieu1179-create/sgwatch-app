import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/services/pusher_service.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/chat/data/datasources/chat_remote_datasource.dart';

class ChatUnreadService {
  ChatUnreadService._();
  static final ChatUnreadService _instance = ChatUnreadService._();
  static ChatUnreadService get instance => _instance;

  static const _pusherChannel = 'chat-channel';
  static const _pusherEvent = 'chat-event';

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  int? _currentUserId;
  bool _isInChatScreen = false;
  bool get isInChatScreen => _isInChatScreen;
  bool _pusherSubscribed = false;

  /// Gọi ở splash: fetch unread count + subscribe Pusher
  static Future<void> prefetchUnreadCount() async {
    try {
      // Lấy current user ID
      final user = await LocalStorage.getUser();
      _instance._currentUserId =
          int.tryParse(user?['id']?.toString() ?? '');
      debugPrint('[ChatUnread] currentUserId=${_instance._currentUserId}');

      // Fetch unread count từ API
      final ds = ChatRemoteDatasource(ApiClient());
      final response = await ds.getHistory(receiverId: 1, page: 1, limit: 1);
      _instance.unreadCount.value = response.unreadCount;
      debugPrint('[ChatUnread] unread=${response.unreadCount}');

      // Subscribe Pusher để lắng nghe tin nhắn mới
      _instance._subscribePusher();
    } catch (e) {
      debugPrint('[ChatUnread] prefetch error: $e');
    }
  }

  /// Subscribe Pusher để tăng unread count khi có tin nhắn mới
  void _subscribePusher() {
    if (_pusherSubscribed) return;
    _pusherSubscribed = true;

    final pusher = PusherService();
    pusher.subscribe(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
    debugPrint('[ChatUnread] Pusher subscribed');
  }

  void _onPusherMessage(Map<String, dynamic> data) {
    debugPrint('[ChatUnread] Pusher message: $data');

    // Nếu user đang ở trong ChatScreen → không tăng (ChatScreen tự xử lý)
    if (_isInChatScreen) {
      debugPrint('[ChatUnread] User is in chat, skip increment');
      return;
    }

    // Chỉ tăng khi tin nhắn gửi cho mình (không phải tin mình gửi)
    final senderId = int.tryParse(data['user_id']?.toString() ?? '');
    if (senderId != null && senderId != _currentUserId) {
      unreadCount.value++;
      debugPrint('[ChatUnread] Incremented to ${unreadCount.value}');
    }
  }

  /// Gọi khi vào ChatScreen
  void enterChat() {
    _isInChatScreen = true;
    unreadCount.value = 0;
    debugPrint('[ChatUnread] enterChat → cleared');
  }

  /// Gọi khi rời ChatScreen
  void leaveChat() {
    _isInChatScreen = false;
    debugPrint('[ChatUnread] leaveChat');
  }

  /// Reset về 0 khi vào chat
  void clearUnread() {
    unreadCount.value = 0;
  }
}
