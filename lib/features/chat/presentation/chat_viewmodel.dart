import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/services/pusher_service.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sgwatch_app/features/chat/data/models/chat_message_model.dart';

class ChatViewModel extends ChangeNotifier {
  static const _receiverId = 1;
  static const _limit = 20;
  static const _pusherChannel = 'chat-channel';
  static const _pusherEvent = 'chat-event';

  final _datasource = ChatRemoteDatasource(ApiClient());
  final _picker = ImagePicker();
  final _pusher = PusherService();

  // ── State ──────────────────────────────────────────────────
  final List<ChatMessageModel> _messages = [];
  final List<File> _pendingImages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSending = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int? _currentUserId;

  // ── Getters ────────────────────────────────────────────────
  List<ChatMessageModel> get messages => _messages;
  List<File> get pendingImages => _pendingImages;
  bool get hasPendingImages => _pendingImages.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSending => _isSending;
  String? get error => _error;
  int? get currentUserId => _currentUserId;

  bool isMe(ChatMessageModel msg) => msg.userId == _currentUserId;

  // ── Init ───────────────────────────────────────────────────
  Future<void> initialize() async {
    debugPrint('[ChatVM] ── initialize ──');
    final user = await LocalStorage.getUser();
    _currentUserId = int.tryParse(user?['id']?.toString() ?? '');
    debugPrint('[ChatVM]   currentUserId=$_currentUserId');
    await loadHistory();
    _markAsRead();
    _subscribePusher();
  }

  // ── Mark as read ──────────────────────────────────────────────
  Future<void> _markAsRead() async {
    try {
      await _datasource.markAsRead(chatPartnerId: _receiverId);
    } catch (e) {
      debugPrint('[ChatVM] markAsRead error: $e');
    }
  }

  // ── Pusher subscribe ────────────────────────────────────────
  void _subscribePusher() {
    debugPrint('[ChatVM] ── subscribePusher ──');
    debugPrint('[ChatVM]   channel=$_pusherChannel, event=$_pusherEvent');
    _pusher.subscribe(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
  }

  void _onPusherMessage(Map<String, dynamic> data) {
    debugPrint('[ChatVM] ── Pusher message received ──');
    debugPrint('[ChatVM]   data=$data');
    try {
      final msg = ChatMessageModel.fromJson(data);
      debugPrint('[ChatVM]   parsed: id=${msg.id}, from=${msg.userId}, '
          'to=${msg.receiverId}, type=${msg.messageType}');

      // Chỉ nhận tin nhắn liên quan đến cuộc hội thoại hiện tại
      final isRelated = msg.userId == _currentUserId ||
          msg.receiverId == _currentUserId;
      if (!isRelated) {
        debugPrint('[ChatVM]   SKIPPED: not related to user $_currentUserId');
        return;
      }

      // Tránh trùng lặp (tin đã gửi qua REST)
      final exists = _messages.any((m) => m.id == msg.id);
      if (exists) {
        debugPrint('[ChatVM]   SKIPPED: duplicate id=${msg.id}');
        return;
      }

      _messages.add(msg);
      debugPrint('[ChatVM]   ADDED to messages (total=${_messages.length})');
      notifyListeners();
    } catch (e) {
      debugPrint('[ChatVM] Pusher parse error: $e');
    }
  }

  // ── Load page 1 (tin mới nhất) ────────────────────────────
  Future<void> loadHistory() async {
    debugPrint('[ChatVM] ── loadHistory ──');
    _isLoading = true;
    _error = null;
    _messages.clear();
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _datasource.getHistory(
        receiverId: _receiverId,
        page: 1,
        limit: _limit,
      );
      // API trả tin mới nhất trước → reverse để tin cũ ở trên
      _messages.addAll(response.messages.reversed);
      _currentPage = response.currentPage;
      _hasMore = response.hasMore;
      debugPrint('[ChatVM]   loaded ${_messages.length} messages, '
          'page=$_currentPage, hasMore=$_hasMore');
    } catch (e) {
      _error = 'Không thể tải tin nhắn.';
      debugPrint('[ChatVM]   loadHistory ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load more (tin cũ hơn) — khi scroll lên ───────────────
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final nextPage = _currentPage + 1;
    debugPrint('[ChatVM] ── loadMore page=$nextPage ──');
    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _datasource.getHistory(
        receiverId: _receiverId,
        page: nextPage,
        limit: _limit,
      );
      // Prepend tin cũ hơn vào đầu list
      final older = response.messages.reversed.toList();
      _messages.insertAll(0, older);
      _currentPage = response.currentPage;
      _hasMore = response.hasMore;
      debugPrint('[ChatVM]   prepended ${older.length} messages, '
          'total=${_messages.length}, hasMore=$_hasMore');
    } catch (e) {
      debugPrint('[ChatVM]   loadMore ERROR: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Gửi tin nhắn ─────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.isEmpty && _pendingImages.isEmpty) return;
    debugPrint('[ChatVM] ── sendMessage ──');
    debugPrint('[ChatVM]   text="${text.length > 50 ? '${text.substring(0, 50)}...' : text}", '
        'images=${_pendingImages.length}');
    _isSending = true;
    notifyListeners();

    try {
      // Gửi pending images trước
      for (int i = 0; i < _pendingImages.length; i++) {
        debugPrint('[ChatVM]   sending image ${i + 1}/${_pendingImages.length}');
        final sent = await _datasource.sendMessage(
          receiverId: _receiverId,
          file: _pendingImages[i],
        );
        // Tránh trùng nếu Pusher đã nhận trước REST response
        if (!_messages.any((m) => m.id == sent.id)) {
          _messages.add(sent);
        }
        debugPrint('[ChatVM]   image sent, id=${sent.id}');
        notifyListeners();
      }
      _pendingImages.clear();

      // Gửi text
      if (text.isNotEmpty) {
        final sent = await _datasource.sendMessage(
          receiverId: _receiverId,
          message: text,
        );
        if (!_messages.any((m) => m.id == sent.id)) {
          _messages.add(sent);
        }
        debugPrint('[ChatVM]   text sent, id=${sent.id}');
      }
    } catch (e) {
      debugPrint('[ChatVM]   sendMessage ERROR: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ── Gửi tin nhắn sản phẩm ────────────────────────────────
  Future<void> sendProductMessage({
    required String imageUrl,
    required String text,
  }) async {
    debugPrint('[ChatVM] ── sendProductMessage ──');
    debugPrint('[ChatVM]   imageUrl=$imageUrl');
    debugPrint('[ChatVM]   text="$text"');
    _isSending = true;
    notifyListeners();

    try {
      // 1) Gửi ảnh sản phẩm trước (nếu có)
      if (imageUrl.isNotEmpty) {
        debugPrint('[ChatVM]   downloading product image...');
        final imageFile = await _downloadImageToTemp(imageUrl);
        if (imageFile != null) {
          debugPrint('[ChatVM]   downloaded → ${imageFile.path}');
          final imgMsg = await _datasource.sendMessage(
            receiverId: _receiverId,
            file: imageFile,
          );
          // Tránh trùng nếu Pusher đã nhận trước REST response
          if (!_messages.any((m) => m.id == imgMsg.id)) {
            _messages.add(imgMsg);
          }
          debugPrint('[ChatVM]   image sent, id=${imgMsg.id}');
          notifyListeners();
        } else {
          debugPrint('[ChatVM]   download failed, skipping image');
        }
      }

      // 2) Gửi text riêng
      if (text.isNotEmpty) {
        final textMsg = await _datasource.sendMessage(
          receiverId: _receiverId,
          message: text,
        );
        if (!_messages.any((m) => m.id == textMsg.id)) {
          _messages.add(textMsg);
        }
        debugPrint('[ChatVM]   text sent, id=${textMsg.id}');
      }
    } catch (e) {
      debugPrint('[ChatVM]   sendProductMessage ERROR: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<File?> _downloadImageToTemp(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      debugPrint('[ChatVM]   downloading: $url → $filePath');
      await Dio().download(url, filePath);
      final file = File(filePath);
      debugPrint('[ChatVM]   download OK, size=${await file.length()} bytes');
      return file;
    } catch (e) {
      debugPrint('[ChatVM]   download ERROR: $e');
      return null;
    }
  }

  // ── Pick images ───────────────────────────────────────────
  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    for (final xFile in picked) {
      _pendingImages.add(File(xFile.path));
    }
    notifyListeners();
  }

  Future<void> pickFromCamera() async {
    debugPrint('[ChatVM] ── pickFromCamera ──');
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      debugPrint('[ChatVM]   pickImage result: ${picked?.path ?? 'null'}');
      if (picked == null) return;
      _pendingImages.add(File(picked.path));
      notifyListeners();
    } catch (e) {
      debugPrint('[ChatVM]   pickFromCamera ERROR: $e');
    }
  }

  void removePendingImage(int index) {
    if (index >= 0 && index < _pendingImages.length) {
      _pendingImages.removeAt(index);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pusher.removeListener(
      channelName: _pusherChannel,
      eventName: _pusherEvent,
      onEvent: _onPusherMessage,
    );
    super.dispose();
  }
}
