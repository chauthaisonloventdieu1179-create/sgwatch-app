import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_conversation_model.dart';
import 'package:sgwatch_app/features/admin/presentation/chat/admin_chat_room_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final _ds = AdminDatasource(ApiClient());
  final _scrollController = ScrollController();

  List<AdminConversationModel> _conversations = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadConversations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
            const Divider(height: 1, indent: 72),
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
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage:
                conv.avatarUrl != null ? NetworkImage(conv.avatarUrl!) : null,
            child: conv.avatarUrl == null
                ? Text(
                    conv.fullName.isNotEmpty
                        ? conv.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                : null,
          ),
          if (conv.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: Text(
                  conv.unreadCount > 99
                      ? '99+'
                      : '${conv.unreadCount}',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conv.fullName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: conv.unreadCount > 0
              ? FontWeight.bold
              : FontWeight.normal,
          color: AppColors.black,
        ),
      ),
      subtitle: conv.latestMessage != null
          ? Text(
              conv.latestMessage!.message.isEmpty ? '[File]' : conv.latestMessage!.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: conv.unreadCount > 0
                    ? AppColors.black
                    : AppColors.grey,
                fontWeight: conv.unreadCount > 0
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            )
          : null,
      trailing: conv.latestMessage != null
          ? Text(
              _formatTime(conv.latestMessage!.createdAt),
              style: TextStyle(
                  fontSize: 11,
                  color: conv.unreadCount > 0
                      ? AppColors.primary
                      : AppColors.grey),
            )
          : null,
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
        // Refresh to update unread counts
        _loadConversations();
      },
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
