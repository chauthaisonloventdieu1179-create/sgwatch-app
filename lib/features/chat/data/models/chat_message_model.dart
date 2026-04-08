int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  return 0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class ChatMessageModel {
  final int id;
  final int userId;
  final String? senderName;
  final String? senderAvatar;
  final int receiverId;
  final String? receiverName;
  final String? receiverAvatar;
  final String? message;
  final String messageType; // "text" | "file"
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  final bool isRead;
  final String? readAt;
  final DateTime createdAt;
  final int? replyToMessageId;
  final ReplyMessage? replyToMessage;

  const ChatMessageModel({
    required this.id,
    required this.userId,
    this.senderName,
    this.senderAvatar,
    required this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.message,
    this.messageType = 'text',
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.replyToMessageId,
    this.replyToMessage,
  });

  bool get isFile => messageType == 'file' && fileUrl != null;

  bool get isImageFile {
    if (!isFile) return false;
    final type = fileType?.toLowerCase() ?? '';
    return type.startsWith('image/');
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      senderName: json['sender_name'] as String? ?? json['user_name'] as String?,
      senderAvatar: json['sender_avatar'] as String? ?? json['user_avatar'] as String?,
      receiverId: _parseInt(json['receiver_id']),
      receiverName: json['receiver_name'] as String?,
      receiverAvatar: json['receiver_avatar'] as String?,
      message: json['message'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: _parseIntNullable(json['file_size']),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      replyToMessageId: _parseIntNullable(json['reply_to_message_id']),
      replyToMessage: json['reply_to_message'] != null
          ? ReplyMessage.fromJson(json['reply_to_message'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReplyMessage {
  final int id;
  final int userId;
  final String? userName;
  final String? message;
  final String messageType;
  final DateTime createdAt;

  const ReplyMessage({
    required this.id,
    required this.userId,
    this.userName,
    this.message,
    this.messageType = 'text',
    required this.createdAt,
  });

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: json['user_name'] as String?,
      message: json['message'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
