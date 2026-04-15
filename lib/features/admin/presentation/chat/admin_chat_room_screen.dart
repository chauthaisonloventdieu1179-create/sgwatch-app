import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/services/pusher_service.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sgwatch_app/features/chat/data/models/chat_message_model.dart';

class AdminChatRoomScreen extends StatefulWidget {
  final int receiverId;
  final String userName;

  const AdminChatRoomScreen({
    super.key,
    required this.receiverId,
    required this.userName,
  });

  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  static const _pusherChannel = 'chat-channel';
  static const _pusherEvent = 'chat-event';
  static const _limit = 50;

  final _datasource = ChatRemoteDatasource(ApiClient());
  final _pusher = PusherService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  final List<ChatMessageModel> _messages = [];
  final List<File> _pendingImages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSending = false;
  int _currentPage = 0;
  bool _hasMore = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  Future<void> _init() async {
    final user = await LocalStorage.getUser();
    _currentUserId =
        int.tryParse(user?['id']?.toString() ?? '');
    await _loadHistory();
    _markAsRead();
    _subscribePusher();
  }

  void _onScroll() {
    // Load older messages when user scrolls up past 50% of content
    final pos = _scrollController.position;
    if (pos.maxScrollExtent > 0 &&
        pos.pixels <= pos.maxScrollExtent * 0.5) {
      _loadMore();
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _messages.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    try {
      final resp = await _datasource.getHistory(
        receiverId: widget.receiverId,
        page: 1,
        limit: _limit,
      );
      setState(() {
        _messages.addAll(resp.messages.reversed);
        _currentPage = resp.currentPage;
        _hasMore = resp.hasMore;
      });
      // Scroll to bottom to show newest messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent);
        }
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final nextPage = _currentPage + 1;
    setState(() => _isLoadingMore = true);
    try {
      final resp = await _datasource.getHistory(
        receiverId: widget.receiverId,
        page: nextPage,
        limit: _limit,
      );
      final older = resp.messages.reversed.toList();
      setState(() {
        _messages.insertAll(0, older);
        _currentPage = resp.currentPage;
        _hasMore = resp.hasMore;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _datasource.markAsRead(chatPartnerId: widget.receiverId);
    } catch (_) {}
  }

  void _subscribePusher() {
    _pusher.subscribe(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
  }

  void _onPusherMessage(Map<String, dynamic> data) {
    try {
      final msg = ChatMessageModel.fromJson(data);
      // Only show messages between admin and this specific user
      final isRelated =
          (msg.userId == widget.receiverId &&
                  msg.receiverId == _currentUserId) ||
              (msg.userId == _currentUserId &&
                  msg.receiverId == widget.receiverId);
      if (!isRelated) return;
      final exists = _messages.any((m) => m.id == msg.id);
      if (exists) return;
      setState(() => _messages.add(msg));
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingImages.isEmpty) return;
    _controller.clear();

    setState(() => _isSending = true);
    try {
      for (final img in List.of(_pendingImages)) {
        final sent = await _datasource.sendMessage(
          receiverId: widget.receiverId,
          file: img,
        );
        if (!_messages.any((m) => m.id == sent.id)) {
          setState(() => _messages.add(sent));
        }
      }
      setState(() => _pendingImages.clear());

      if (text.isNotEmpty) {
        final sent = await _datasource.sendMessage(
          receiverId: widget.receiverId,
          message: text,
        );
        if (!_messages.any((m) => m.id == sent.id)) {
          setState(() => _messages.add(sent));
        }
      }
    } catch (_) {
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() {
      for (final f in picked) {
        _pendingImages.add(File(f.path));
      }
    });
  }

  @override
  void dispose() {
    _pusher.removeListener(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isMe(ChatMessageModel msg) => msg.userId == _currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userName,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_pendingImages.isNotEmpty) _buildPendingImages(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text('Chưa có tin nhắn',
            style: TextStyle(color: AppColors.grey)),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (index == 0 && _isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
          );
        }
        final adjustedIndex = _isLoadingMore ? index - 1 : index;
        return _buildBubble(_messages[adjustedIndex]);
      },
    );
  }

  Widget _buildBubble(ChatMessageModel msg) {
    final me = _isMe(msg);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            me ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!me) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: msg.isImageFile
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: me ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(me ? 16 : 4),
                      bottomRight: Radius.circular(me ? 4 : 16),
                    ),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: msg.isImageFile
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            msg.fileUrl!,
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.broken_image,
                                  color: AppColors.grey),
                            ),
                          ),
                        )
                      : msg.isFile
                          ? _buildFileMessage(msg, me)
                          : Text(
                              msg.message ?? '',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: me
                                      ? AppColors.white
                                      : AppColors.black),
                            ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatDateTime(msg.createdAt),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.grey),
                ),
              ],
            ),
          ),
          if (me) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFileMessage(ChatMessageModel msg, bool me) {
    return GestureDetector(
      onTap: () {
        if (msg.fileUrl != null) {
          Clipboard.setData(ClipboardData(text: msg.fileUrl!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã sao chép link file')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file,
                color: me ? AppColors.white : AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                msg.fileName ?? 'File',
                style: TextStyle(
                    fontSize: 13,
                    color: me ? AppColors.white : AppColors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingImages() {
    return Container(
      height: 80,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pendingImages.length,
        itemBuilder: (_, i) => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_pendingImages[i],
                    width: 70, height: 70, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 0,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _pendingImages.removeAt(i)),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: AppColors.grey),
            onPressed: _pickImages,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Nhắn tin...',
                hintStyle:
                    const TextStyle(color: AppColors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send,
                      color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
