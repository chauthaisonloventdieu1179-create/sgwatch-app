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
import 'package:url_launcher/url_launcher.dart';

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
  ChatMessageModel? _replyToMessage;

  static final _urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);

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
    final replyId = _replyToMessage?.id;
    setState(() {
      _isSending = true;
      _replyToMessage = null;
    });

    try {
      for (final img in List.of(_pendingImages)) {
        final sent = await _datasource.sendMessage(
          receiverId: widget.receiverId,
          file: img,
          replyToMessageId: replyId,
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
          replyToMessageId: replyId,
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

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.black),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.black),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() {
      for (final f in picked) {
        _pendingImages.add(File(f.path));
      }
    });
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() => _pendingImages.add(File(picked.path)));
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
          if (_replyToMessage != null) _buildReplyBar(),
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
    return GestureDetector(
      onLongPress: () => setState(() => _replyToMessage = msg),
      child: Padding(
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
                  msg.isImageFile
                      ? GestureDetector(
                          onTap: () => _openImageViewer(msg.fileUrl!),
                          child: ClipRRect(
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
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: me
                                ? const Color(0xFFFFE0DE)
                                : AppColors.white,
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
                          child: msg.isFile
                              ? _buildFileMessage(msg, me)
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (msg.replyToMessage != null) ...[
                                      _buildReplyPreview(msg.replyToMessage!, isMine: me),
                                      const SizedBox(height: 6),
                                    ],
                                    _buildTextWithLinks(
                                      msg.message ?? '',
                                      textColor: AppColors.black,
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildReplyBar() {
    final reply = _replyToMessage!;
    final me = _isMe(reply);
    final senderName = me ? 'Bạn' : widget.userName;
    final previewText = (reply.message != null && reply.message!.trim().isNotEmpty)
        ? reply.message!.replaceAll('\n', ' ')
        : '📎 Hình ảnh';

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  previewText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.grey),
            onPressed: () => setState(() => _replyToMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ReplyMessage reply, {required bool isMine}) {
    final bgColor = isMine
        ? const Color(0xFFFFCCC9)
        : const Color(0xFFF0F0F0);
    final previewText = (reply.message != null && reply.message!.trim().isNotEmpty)
        ? reply.message!.replaceAll('\n', ' ')
        : '📎 Hình ảnh';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            reply.userName ?? 'Unknown',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithLinks(String text, {Color textColor = AppColors.black}) {
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final match in _urlRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
        ));
      }
      final url = match.group(0)!;
      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () async {
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            url,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              height: 1.4,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
            ),
          ),
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
      ));
    }
    if (spans.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 14, color: textColor, height: 1.4));
    }
    return RichText(text: TextSpan(children: spans));
  }

  void _openImageViewer(String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullScreenImageViewer(imageUrl: imageUrl),
    ));
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
            onPressed: _showImageSourceSheet,
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

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  const _FullScreenImageViewer({required this.imageUrl});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.white54),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
