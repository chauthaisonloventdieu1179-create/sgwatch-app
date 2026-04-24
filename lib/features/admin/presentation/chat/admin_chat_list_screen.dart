import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/services/pusher_service.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_conversation_model.dart';
import 'package:sgwatch_app/features/admin/presentation/chat/admin_chat_room_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  /// Notification service set cái này để mở thẳng room chat
  /// Map: {'receiverId': int, 'userName': String}
  static final ValueNotifier<Map<String, dynamic>?> openRoomNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  static const _pusherChannel = 'chat-channel';
  static const _pusherEvent = 'chat-event';

  // Cache tĩnh giữ list qua navigation
  static List<AdminConversationModel>? _cache;

  final _ds = AdminDatasource(ApiClient());
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _pusher = PusherService();
  Timer? _debounceTimer;
  Timer? _searchDebounce;

  List<AdminConversationModel> _conversations = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    // Hiện cache ngay nếu có, rồi silent refresh để sync
    if (_cache != null && _cache!.isNotEmpty) {
      _conversations = List.from(_cache!);
      _silentRefresh();
    } else {
      _loadConversations();
    }
    _pusher.subscribe(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
    AdminChatListScreen.openRoomNotifier.addListener(_onExternalOpenRoom);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onExternalOpenRoom());
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final q = _searchController.text.trim();
      if (q != _searchQuery) {
        _searchQuery = q;
        _loadConversations();
      }
    });
  }

  void _onPusherMessage(Map<String, dynamic> _) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), _silentRefresh);
  }

  /// Fetch page 1, merge in-place: update item theo ID, thêm conv mới lên đầu, sort lại
  Future<void> _silentRefresh() async {
    if (_searchQuery.isNotEmpty) return; // don't override search results
    try {
      final res = await _ds.getConversations(page: 1);
      if (!mounted) return;

      final newMap = {for (final c in res.conversations) c.id: c};
      final existingIds = <int>{};
      final merged = <AdminConversationModel>[];

      // Cập nhật items đang có
      for (final conv in _conversations) {
        existingIds.add(conv.id);
        merged.add(newMap[conv.id] ?? conv);
      }

      // Thêm conv mới chưa có trong list
      for (final conv in res.conversations) {
        if (!existingIds.contains(conv.id)) {
          merged.insert(0, conv);
        }
      }

      // Sort theo tin nhắn mới nhất
      merged.sort((a, b) {
        final ta = a.latestMessage?.createdAt ?? '';
        final tb = b.latestMessage?.createdAt ?? '';
        return tb.compareTo(ta);
      });

      _conversations = merged;
      _hasMore = res.currentPage < res.totalPages;
      _currentPage = res.currentPage;
      _cache = List.from(_conversations);

      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _onExternalOpenRoom() {
    final req = AdminChatListScreen.openRoomNotifier.value;
    if (req != null && mounted) {
      AdminChatListScreen.openRoomNotifier.value = null;
      final receiverId = req['receiverId'] as int;
      final userName = req['userName'] as String;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminChatRoomScreen(
            receiverId: receiverId,
            userName: userName,
          ),
        ),
      ).then((_) => _silentRefresh());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _pusher.removeListener(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
    AdminChatListScreen.openRoomNotifier.removeListener(_onExternalOpenRoom);
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.maxScrollExtent > 0 &&
        pos.pixels >= pos.maxScrollExtent * 0.5) {
      _loadMore();
    }
  }

  Future<void> _loadConversations() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _conversations = [];
      _currentPage = 1;
      _hasMore = true;
    });
    final query = _searchQuery.isNotEmpty ? _searchQuery : null;
    try {
      final res = await _ds.getConversations(page: 1, search: query);
      setState(() {
        _conversations = res.conversations;
        _hasMore = res.currentPage < res.totalPages;
        _currentPage = res.currentPage;
        if (query == null) _cache = List.from(_conversations);
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    final nextPage = _currentPage + 1;
    setState(() => _isLoading = true);
    final query = _searchQuery.isNotEmpty ? _searchQuery : null;
    try {
      final res = await _ds.getConversations(page: nextPage, search: query);
      setState(() {
        _conversations.addAll(res.conversations);
        _hasMore = res.currentPage < res.totalPages;
        _currentPage = res.currentPage;
        if (query == null) _cache = List.from(_conversations);
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khách hàng...',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.greyPlaceholder),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                  },
                  child: const Icon(Icons.close, color: AppColors.grey, size: 18),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
          filled: true,
          fillColor: AppColors.backgroundGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _conversations.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 48, color: AppColors.grey),
            const SizedBox(height: 12),
            const Text('Không có tin nhắn',
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadConversations,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _conversations.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 80, endIndent: 0, thickness: 0.5),
        itemBuilder: (ctx, index) {
          if (index == _conversations.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              ),
            );
          }
          return _buildConversationTile(_conversations[index]);
        },
      ),
    );
  }

  Widget _buildConversationTile(AdminConversationModel conv) {
    final hasUnread = conv.unreadCount > 0;
    final initials = conv.fullName.isNotEmpty
        ? conv.fullName[0].toUpperCase()
        : '?';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminChatRoomScreen(
              receiverId: conv.id,
              userName: conv.fullName,
            ),
          ),
        ).then((_) => _silentRefresh());
      },
      child: Container(
        color: hasUnread
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    image: conv.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(conv.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: conv.avatarUrl == null
                      ? Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        )
                      : null,
                ),
                if (hasUnread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      constraints: const BoxConstraints(
                          minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conv.unreadCount > 99
                            ? '99+'
                            : '${conv.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (conv.latestMessage != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(conv.latestMessage!.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.grey,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (conv.latestMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      conv.latestMessage!.message.isEmpty
                          ? '📎 File đính kèm'
                          : conv.latestMessage!.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasUnread ? AppColors.black : AppColors.grey,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt.replaceAll(' ', 'T')).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Hôm qua';
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {
      return '';
    }
  }
}
