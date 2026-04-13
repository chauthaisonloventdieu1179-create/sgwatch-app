import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/services/notification_unread_service.dart';
import 'package:sgwatch_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:sgwatch_app/features/notifications/data/models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final _datasource = NotificationRemoteDatasource(ApiClient());
  static const _perPage = 15;

  // ── State ──────────────────────────────────────────────────
  final List<NotificationModel> _allNotifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int _selectedTab = 0;

  // ── Getters ────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get selectedTab => _selectedTab;

  List<NotificationModel> get notifications {
    if (_selectedTab == 0) {
      return _allNotifications.where((n) => n.isOrderType).toList();
    }
    return _allNotifications.where((n) => n.isSystemType).toList();
  }

  bool get isEmpty => notifications.isEmpty;

  // ── Tab ────────────────────────────────────────────────────
  void selectTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
    // Auto-load more nếu tab hiện tại ít items mà vẫn còn page
    _autoLoadIfNeeded();
  }

  // ── Load page 1 ───────────────────────────────────────────
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    _allNotifications.clear();
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _datasource.getNotices(
        page: 1,
        perPage: _perPage,
      );
      _allNotifications.addAll(response.notices);
      _currentPage = response.currentPage;
      _hasMore = response.hasMore;
    } catch (e) {
      _error = 'Không thể tải thông báo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _autoLoadIfNeeded();
  }

  // ── Load next page ────────────────────────────────────────
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _datasource.getNotices(
        page: nextPage,
        perPage: _perPage,
      );
      _allNotifications.addAll(response.notices);
      _currentPage = response.currentPage;
      _hasMore = response.hasMore;
    } catch (_) {}

    _isLoadingMore = false;
    notifyListeners();
  }

  // Nếu tab hiện tại < 5 items mà vẫn còn page → tự load thêm
  void _autoLoadIfNeeded() {
    if (notifications.length < 5 && _hasMore && !_isLoading && !_isLoadingMore) {
      loadMore();
    }
  }

  /// Đánh dấu đã đọc: cập nhật local + gọi API + giảm badge
  Future<void> markAsRead(String id) async {
    final index = _allNotifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final n = _allNotifications[index];
    if (n.isRead) return;

    // Cập nhật local ngay lập tức
    _allNotifications[index] = NotificationModel(
      id: n.id,
      type: n.type,
      title: n.title,
      content: n.content,
      imageUrl: n.imageUrl,
      data: n.data,
      readAt: DateTime.now(),
      createdAt: n.createdAt,
    );
    NotificationUnreadService.instance.decrement();
    notifyListeners();

    // Gọi API để server đánh dấu đã đọc (fire & forget)
    try {
      await _datasource.getNoticeDetail(id);
    } catch (_) {}
  }
}
