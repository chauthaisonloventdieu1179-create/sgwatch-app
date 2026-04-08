import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/chat/data/models/chat_message_model.dart';

class ChatRemoteDatasource {
  final ApiClient _apiClient;

  ChatRemoteDatasource(this._apiClient);

  /// GET /chat/history/list?receiver_id=1&limit=20&page=1
  Future<ChatHistoryResponse> getHistory({
    required int receiverId,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('[ChatDS] ── GET history ──');
    debugPrint('[ChatDS]   receiver=$receiverId, page=$page, limit=$limit');
    final response = await _apiClient.get(
      Endpoints.chatHistory,
      queryParameters: {
        'receiver_id': receiverId,
        'page': page,
        'limit': limit,
      },
    );

    debugPrint('[ChatDS]   status=${response.statusCode}');
    final data = response.data['data'];
    final list = (data['messages'] as List)
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>?;
    final currentPage = pagination?['current_page'] as int? ?? page;
    final totalPages = pagination?['total_pages'] as int? ??
        (list.length < limit ? page : page + 1);
    final unreadCount = data['unread_count'] as int? ?? 0;

    debugPrint('[ChatDS]   messages=${list.length}, '
        'page=$currentPage/$totalPages, unread=$unreadCount');

    return ChatHistoryResponse(
      messages: list,
      currentPage: currentPage,
      totalPages: totalPages,
      hasMore: currentPage < totalPages,
      unreadCount: unreadCount,
    );
  }

  /// POST /chat/messages/mark-as-read
  Future<void> markAsRead({required int chatPartnerId}) async {
    debugPrint('[ChatDS] ── POST mark-as-read partner=$chatPartnerId ──');
    final response = await _apiClient.post(
      Endpoints.chatMarkAsRead,
      data: {'chat_partner_id': chatPartnerId},
    );
    final data = response.data['data'];
    debugPrint('[ChatDS]   marked_count=${data['marked_count']}');
  }

  /// POST /chat/message (form-data)
  Future<ChatMessageModel> sendMessage({
    required int receiverId,
    String? message,
    File? file,
    int? replyToMessageId,
  }) async {
    debugPrint('[ChatDS] ── POST message ──');
    debugPrint('[ChatDS]   receiver=$receiverId, '
        'message=${message != null ? '"${message.length > 50 ? '${message.substring(0, 50)}...' : message}"' : 'null'}, '
        'file=${file?.path.split('/').last ?? 'null'}, '
        'replyTo=$replyToMessageId');

    final formMap = <String, dynamic>{
      'receiver_id': receiverId,
    };
    if (message != null && message.isNotEmpty) {
      formMap['message'] = message;
    }
    if (file != null) {
      formMap['file'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    }
    if (replyToMessageId != null) {
      formMap['reply_to_message_id'] = replyToMessageId;
    }

    try {
      final response = await _apiClient.post(
        Endpoints.chatSendMessage,
        data: FormData.fromMap(formMap),
      );

      debugPrint('[ChatDS]   status=${response.statusCode}');
      final msgData = response.data['data'] as Map<String, dynamic>;
      debugPrint('[ChatDS]   response id=${msgData['id']}, '
          'type=${msgData['message_type']}, '
          'fileUrl=${msgData['file_url'] ?? 'null'}');
      return ChatMessageModel.fromJson(msgData);
    } on DioException catch (e) {
      debugPrint('[ChatDS]   ❌ ERROR status=${e.response?.statusCode}');
      debugPrint('[ChatDS]   ❌ response body=${e.response?.data}');
      debugPrint('[ChatDS]   ❌ request path=${e.requestOptions.path}');
      debugPrint('[ChatDS]   ❌ request headers=${e.requestOptions.headers}');
      rethrow;
    }
  }
}

class ChatHistoryResponse {
  final List<ChatMessageModel> messages;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final int unreadCount;

  const ChatHistoryResponse({
    required this.messages,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    required this.unreadCount,
  });
}
