import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/services/chat_unread_service.dart';
import 'package:sgwatch_app/app/app.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/features/admin/presentation/admin_scaffold.dart';
import 'package:sgwatch_app/features/admin/presentation/chat/admin_chat_list_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_all_orders_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_manager_screen.dart';
import 'package:sgwatch_app/features/chat/presentation/chat_screen.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_viewmodel.dart';

// ─── Background handler (BẮT BUỘC top-level function) ────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
  debugPrint('[FCM]   title=${message.notification?.title}');
  debugPrint('[FCM]   body=${message.notification?.body}');
  debugPrint('[FCM]   data=${message.data}');
}

// ─── Service ─────────────────────────────────────────────────────────
class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Android notification channel (heads-up)
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.high,
  );

  /// Khởi tạo toàn bộ FCM + local notifications
  static Future<void> init() async {
    debugPrint('[FCM] ── init ──');

    // 1) Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2) Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        debugPrint('[FCM] Local notification tapped, payload=${resp.payload}');
        if (resp.payload != null) {
          _handleNotificationData(jsonDecode(resp.payload!));
        }
      },
    );

    // 3) Tạo Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 4) iOS: TẮT alert native để tránh double notification
    //    (foreground handler bên dưới đã show bằng local notification)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    // 5) Xin quyền
    await _requestPermission();

    // 6) Lấy FCM token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('[FCM]   token=$token');

    // 7) Lắng nghe token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM]   token refreshed=$newToken');
      registerToken();
    });

    // 8) Foreground: FCM không tự show → hiển thị bằng local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] ── Foreground message ──');
      debugPrint('[FCM]   title=${message.notification?.title}');
      debugPrint('[FCM]   body=${message.notification?.body}');
      debugPrint('[FCM]   data=${message.data}');

      // Tăng unread count nếu là chat notification
      _handleForegroundChatUnread(message.data);

      _showLocalNotification(message);
    });

    // 9) User tap notification khi app ở background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] ── Opened from background ──');
      debugPrint('[FCM]   data=${message.data}');
      _handleNotificationData(message.data);
    });

    // 10) User tap notification khi app terminated
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] ── Opened from terminated ──');
      debugPrint('[FCM]   data=${initialMessage.data}');
      _handleNotificationData(initialMessage.data);
    }
  }

  /// Xin quyền thông báo (iOS prompt + Android 13+)
  static Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM]   permission=${settings.authorizationStatus}');
  }

  /// Tăng unread count khi nhận chat notification ở foreground
  static void _handleForegroundChatUnread(Map<String, dynamic> data) {
    final redirectType = data['redirectType'];
    if (redirectType == 'chat') {
      // ChatUnreadService tự kiểm tra isInChatScreen bên trong
      // Nếu user đang ở ChatScreen → không tăng
      // Ở đây chỉ cần gọi increment từ FCM data
      final service = ChatUnreadService.instance;
      if (!service.isInChatScreen) {
        service.unreadCount.value++;
        debugPrint('[FCM] Chat unread incremented to ${service.unreadCount.value}');
      }
    }
  }

  /// Hiển thị local notification khi app đang foreground
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(
      notif.hashCode,
      notif.title,
      notif.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Xử lý khi user tap notification → navigate tới màn hình tương ứng
  static void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint('[FCM] Handle notification data: $data');

    final redirectType = data['redirectType'];
    final isAdmin = ProfileViewModel.cachedRole == 'admin';

    if (redirectType == 'chat') {
      if (isAdmin) {
        _navigateToAdminChatList(data: data);
      } else {
        _navigateToChat();
      }
    } else if (redirectType == 'order_detail') {
      if (isAdmin) {
        _navigateToAdminOrders();
      }
    }
  }

  /// Navigate vào ChatScreen (CSKH - user thường)
  static void _navigateToChat() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('[FCM] navigatorKey.currentContext is null, skip navigate');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
    debugPrint('[FCM] Navigated to ChatScreen');
  }

  /// Navigate vào AdminChatListScreen (admin) - chuyển tab thay vì push route
  /// Nếu có senderId trong data → mở thẳng room chat của user đó
  static void _navigateToAdminChatList({Map<String, dynamic>? data}) {
    if (data != null) {
      final senderId = int.tryParse(data['user_id']?.toString() ?? '');
      final senderName = data['user_name']?.toString()
          ?? data['sender_name']?.toString()
          ?? 'Người dùng';
      if (senderId != null) {
        AdminChatListScreen.openRoomNotifier.value = {
          'receiverId': senderId,
          'userName': senderName,
        };
        debugPrint('[FCM] Will open chat room for userId=$senderId name=$senderName');
      }
    }
    AdminScaffold.navigateToTabNotifier.value = 2;
    debugPrint('[FCM] Navigated to AdminChatListScreen via tab switch');
  }

  /// Navigate vào AdminManagerScreen → AdminAllOrdersScreen (admin)
  static void _navigateToAdminOrders() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminManagerScreen()),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminAllOrdersScreen()),
    );
    debugPrint('[FCM] Navigated to AdminAllOrdersScreen');
  }

  /// Lấy FCM token hiện tại
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Gửi FCM token lên server (gọi sau login hoặc khi token refresh)
  static Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      debugPrint('[FCM] ── registerToken ──');
      debugPrint('[FCM]   token=$token');
      await ApiClient().post(Endpoints.fcmToken, data: {'fcm_token': token});
      debugPrint('[FCM]   registered OK');
    } catch (e) {
      debugPrint('[FCM]   registerToken ERROR: $e');
    }
  }
}
