import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sgwatch_app/core/services/chat_unread_service.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/features/chat/data/models/chat_message_model.dart';
import 'package:sgwatch_app/features/chat/presentation/chat_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String? productImageUrl;
  final String? productText;

  const ChatScreen({
    super.key,
    this.productImageUrl,
    this.productText,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    _viewModel.addListener(_onChanged);
    _scrollController.addListener(_onScroll);
    _init();
  }

  Future<void> _init() async {
    await _viewModel.initialize();
    // Đánh dấu đang ở trong chat → không tăng unread count
    ChatUnreadService.instance.enterChat();

    // Gửi tin nhắn sản phẩm nếu có
    if (widget.productText != null && widget.productText!.isNotEmpty) {
      await _viewModel.sendProductMessage(
        imageUrl: widget.productImageUrl ?? '',
        text: widget.productText!,
      );
    }
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  // reverse: true → scroll lên = tiến về maxScrollExtent = tin cũ hơn
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _viewModel.loadMore();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && !_viewModel.hasPendingImages) return;
    _controller.clear();
    await _viewModel.sendMessage(text);
  }

  @override
  void dispose() {
    ChatUnreadService.instance.leaveChat();
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: const Color(0x0D000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tư vấn trực tiếp',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(child: _buildMessageList()),
          // Pending images preview
          if (_viewModel.hasPendingImages) _buildPendingImages(),
          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Message list (reverse: true → tin mới nhất ở bottom) ────
  Widget _buildMessageList() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_viewModel.error != null && _viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _viewModel.error!,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _viewModel.loadHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final msgs = _viewModel.messages;
    final itemCount = msgs.length + (_viewModel.isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // reverse: true → index 0 = bottom = tin mới nhất
        // Loading more indicator ở cuối list = trên cùng màn hình
        if (index == msgs.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }
        // index 0 = newest (msgs.length - 1), index last = oldest (msgs[0])
        final msgIndex = msgs.length - 1 - index;
        final msg = msgs[msgIndex];

        // Group: chỉ hiện avatar/name ở tin đầu tiên của nhóm liên tiếp cùng sender
        final prevMsg = msgIndex > 0 ? msgs[msgIndex - 1] : null;
        final isFirstInGroup = prevMsg == null || prevMsg.userId != msg.userId;

        return _buildMessage(msg, isFirstInGroup: isFirstInGroup);
      },
    );
  }

  // ── Message bubble ─────────────────────────────────────────
  Widget _buildMessage(ChatMessageModel msg, {bool isFirstInGroup = true}) {
    final isMine = _viewModel.isMe(msg);
    final showSenderInfo = !isMine && isFirstInGroup && msg.senderName != null;

    return Padding(
      padding: EdgeInsets.only(bottom: isFirstInGroup ? 12 : 4),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender info (chỉ hiện ở tin đầu nhóm)
          if (showSenderInfo)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  if (msg.senderAvatar != null)
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(msg.senderAvatar!),
                      onBackgroundImageError: (_, __) {},
                      child: const Text('SG',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.white)),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'SG',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    msg.senderName!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          // Bubble
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) const SizedBox(width: 34),
              Flexible(
                child: _isImageContent(msg)
                    ? _buildBubbleContent(msg)
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFFFFE0DE)
                              : AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                                Radius.circular(isMine ? 16 : 4),
                            bottomRight:
                                Radius.circular(isMine ? 4 : 16),
                          ),
                        ),
                        child: _buildBubbleContent(msg),
                      ),
              ),
            ],
          ),
          // Time + read status
          Padding(
            padding: EdgeInsets.only(top: 4, left: isMine ? 0 : 34),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatTime(msg.createdAt),
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: msg.isRead ? Colors.blue : AppColors.grey,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageContent(ChatMessageModel msg) {
    return msg.isImageFile;
  }

  Widget _buildBubbleContent(ChatMessageModel msg) {
    // File ảnh từ server
    if (msg.isImageFile && msg.fileUrl != null) {
      return GestureDetector(
        onTap: () => _openImageViewer(msg.fileUrl!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            msg.fileUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 200,
              height: 100,
              child: Center(
                child: Icon(Icons.broken_image, color: AppColors.grey),
              ),
            ),
          ),
        ),
      );
    }
    // File không phải ảnh
    if (msg.isFile && msg.fileUrl != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 20, color: AppColors.grey),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.fileName ?? 'File',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (msg.fileSize != null)
                  Text(
                    _formatFileSize(msg.fileSize!),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    // Text message
    final text = msg.message ?? '';
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã copy tin nhắn'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: _buildTextWithLinks(text),
    );
  }

  static final _urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  Widget _buildTextWithLinks(String text) {
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in _urlRegex.allMatches(text)) {
      // text thường trước URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 14, color: AppColors.black, height: 1.4),
        ));
      }
      // URL span — clickable
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

    // text còn lại sau URL cuối
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(fontSize: 14, color: AppColors.black, height: 1.4),
      ));
    }

    // Không có URL → Text thường
    if (spans.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppColors.black, height: 1.4),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  // ── Pending images ─────────────────────────────────────────
  Widget _buildPendingImages() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _viewModel.pendingImages.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == _viewModel.pendingImages.length) {
              return GestureDetector(
                onTap: () => _viewModel.pickImages(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add,
                      size: 28, color: AppColors.grey),
                ),
              );
            }
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _viewModel.pendingImages[index],
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _viewModel.removePendingImage(index),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _viewModel.isSending ? null : () => _viewModel.pickImages(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.image_outlined,
                  size: 26,
                  color: _viewModel.isSending
                      ? AppColors.greyLight
                      : AppColors.black),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                enabled: !_viewModel.isSending,
                decoration: const InputDecoration(
                  hintText: 'Gửi tin nhắn...',
                  hintStyle: TextStyle(
                      color: AppColors.greyPlaceholder, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style:
                    const TextStyle(fontSize: 14, color: AppColors.black),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _viewModel.isSending ? null : _sendMessage,
            child: SizedBox(
              width: 40,
              height: 40,
              child: _viewModel.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.send,
                      size: 24, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-screen image viewer ──────────────────────────────────
class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformController =
      TransformationController();

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
                  child: Icon(Icons.broken_image,
                      size: 48, color: Colors.white54),
                ),
              ),
            ),
          ),
          // Close button
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
