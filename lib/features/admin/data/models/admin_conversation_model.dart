class AdminConversationModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final int unreadCount;
  final AdminLastMessage? latestMessage;

  const AdminConversationModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.unreadCount,
    this.latestMessage,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AdminConversationModel.fromJson(Map<String, dynamic> json) {
    return AdminConversationModel(
      id: json['id'] as int,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      unreadCount: json['unread_count'] as int? ?? 0,
      latestMessage: json['latest_message'] != null
          ? AdminLastMessage.fromJson(
              json['latest_message'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AdminLastMessage {
  final int id;
  final String message;
  final String messageType;
  final String userName;
  final int userId;
  final String createdAt;

  const AdminLastMessage({
    required this.id,
    required this.message,
    required this.messageType,
    required this.userName,
    required this.userId,
    required this.createdAt,
  });

  factory AdminLastMessage.fromJson(Map<String, dynamic> json) {
    return AdminLastMessage(
      id: json['id'] as int? ?? 0,
      message: json['message']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
      userName: json['user_name']?.toString() ?? '',
      userId: json['user_id'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
