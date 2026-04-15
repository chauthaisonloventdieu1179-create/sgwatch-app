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

  final _ds = AdminDatasource(ApiClient());
  final _scrollController = ScrollController();
  final _pusher = PusherService();
  Timer? _debounceTimer;

  List<AdminConversationModel> _conversations = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadConversations();
    _pusher.subscribe(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
    AdminChatListScreen.openRoomNotifier.addListener(_onExternalOpenRoom);
    // Xử lý trường hợp notifier đã được set trước khi widget mount
    WidgetsBinding.instance.addPostFrameCallback((_) => _onExternalOpenRoom());
  }

  void _onPusherMessage(Map<String, dynamic> _) {
    // Debounce 1 giây để tránh gọi API liên tục khi nhiều tin đến cùng lúc
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), _silentRefresh);
  }

  Future<void> _silentRefresh() async {
    try {
      final res = await _ds.getConversations(page: 1);
      if (!mounted) return;
      setState(() {
        _conversations = res.conversations;
        _hasMore = res.currentPage < res.totalPages;
        _currentPage = res.currentPage;
      });
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
      ).then((_) => _loadConversations());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
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
    try {
      final res = await _ds.getConversations(page: 1);
      setState(() {
        _conversations = res.conversations;
        _hasMore = res.currentPage < res.totalPages;
        _currentPage = res.currentPage;
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
    try {
      final res = await _ds.getConversations(page: nextPage);
      setState(() {
        _conversations.addAll(res.conversations);
        _hasMore = res.currentPage < res.totalPages;
        _currentPage = res.currentPage;
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
      body: _buildBody(),
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
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminChatRoomScreen(
              receiverId: conv.id,
              userName: conv.fullName,
            ),
          ),
        );
        _loadConversations();
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
      final dt = DateTime.parse(createdAt.replaceAll(' ', 'T'));
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
