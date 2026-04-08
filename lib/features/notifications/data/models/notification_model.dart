class NotificationModel {
  final String id;
  final String type; // "order_status", "payment_status", "system"
  final String title;
  final String content;
  final String? imageUrl;
  final NotificationData? data;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.imageUrl,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;
  bool get isOrderType => type == 'order_status' || type == 'payment_status';
  bool get isSystemType => type == 'system';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      data: json['data'] != null
          ? NotificationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationData {
  final int? orderId;
  final String? orderNumber;
  final String? paymentStatus;
  final String? oldStatus;
  final String? newStatus;

  const NotificationData({
    this.orderId,
    this.orderNumber,
    this.paymentStatus,
    this.oldStatus,
    this.newStatus,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      orderId: json['order_id'] as int?,
      orderNumber: json['order_number'] as String?,
      paymentStatus: json['payment_status'] as String?,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String?,
    );
  }
}
