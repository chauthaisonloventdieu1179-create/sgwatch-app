import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

enum OrderStatus {
  pending,
  shipping,
  completed,
  cancelled,
  refunded;

  static OrderStatus fromString(String s) {
    switch (s) {
      case 'pending':
        return OrderStatus.pending;
      case 'shipping':
        return OrderStatus.shipping;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.shipping:
        return 'Chờ giao hàng';
      case OrderStatus.completed:
        return 'Đã hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.refunded:
        return 'Hoàn tiền';
    }
  }

  String get apiValue => name;

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800);
      case OrderStatus.shipping:
        return const Color(0xFF2196F3);
      case OrderStatus.completed:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return AppColors.primary;
      case OrderStatus.refunded:
        return const Color(0xFF9C27B0);
    }
  }
}

/// Dùng cho danh sách đơn hàng (GET /shop/orders?status=...)
class OrderListItem {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final String paymentStatus;
  final String paymentMethod;
  final String shippingMethod;
  final double totalAmount;
  final String currency;
  final int totalItems;
  final DateTime createdAt;

  const OrderListItem({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.totalAmount,
    required this.currency,
    required this.totalItems,
    required this.createdAt,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      paymentStatus: json['payment_status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      shippingMethod: json['shipping_method'] as String? ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      currency: json['currency'] as String? ?? 'JPY',
      totalItems: json['total_items'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Sản phẩm trong chi tiết đơn hàng
class OrderDetailItem {
  final int id;
  final int productId;
  final String productName;
  final String productSku;
  final String productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderDetailItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String? ?? '',
      productSku: json['product_sku'] as String? ?? '',
      productImage: json['product_image'] as String? ?? '',
      quantity: json['quantity'] as int,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0.0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
    );
  }
}

/// Chi tiết đơn hàng (GET /shop/orders/{id})
class OrderDetailModel {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final String paymentStatus;
  final String paymentMethod;
  final String? paymentReceipt;
  final String shippingMethod;
  final double subtotal;
  final double shippingFee;
  final double codFee;
  final double stripeFee;
  final double depositAmount;
  final double discountAmount;
  final int pointsUsed;
  final int pointsEarned;
  final double totalAmount;
  final String currency;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final String shippingCity;
  final String shippingCountry;
  final String shippingPostalCode;

  bool get isVietnamAddress {
    final lower = shippingCountry.toLowerCase();
    return lower.contains('vn') ||
        lower.contains('vietnam') ||
        lower.contains('vi\u1ec7t');
  }

  bool get needsPayment =>
      paymentStatus == 'pending' &&
      (paymentMethod == 'bank_transfer' ||
          paymentMethod == 'deposit_transfer');
  final String? note;
  final String? trackingNumber;
  final String? shippingCarrier;
  final String? cancelReason;
  final DateTime? confirmedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final List<OrderDetailItem> items;

  const OrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.paymentReceipt,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.codFee,
    required this.stripeFee,
    required this.depositAmount,
    required this.discountAmount,
    required this.pointsUsed,
    required this.pointsEarned,
    required this.totalAmount,
    required this.currency,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingCountry,
    required this.shippingPostalCode,
    this.note,
    this.trackingNumber,
    this.shippingCarrier,
    this.cancelReason,
    this.confirmedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v != null ? DateTime.parse(v as String) : null;

    return OrderDetailModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      paymentStatus: json['payment_status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentReceipt: json['payment_receipt'] as String?,
      shippingMethod: json['shipping_method'] as String? ?? '',
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      shippingFee: double.tryParse(json['shipping_fee'].toString()) ?? 0.0,
      codFee: double.tryParse(json['cod_fee'].toString()) ?? 0.0,
      stripeFee: (json['stripe_fee'] as num?)?.toDouble() ?? 0.0,
      depositAmount: double.tryParse(json['deposit_amount'].toString()) ?? 0.0,
      discountAmount:
          double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      pointsUsed: json['points_used'] as int? ?? 0,
      pointsEarned: json['points_earned'] as int? ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      currency: json['currency'] as String? ?? 'JPY',
      shippingName: json['shipping_name'] as String? ?? '',
      shippingPhone: json['shipping_phone'] as String? ?? '',
      shippingAddress: json['shipping_address'] as String? ?? '',
      shippingCity: json['shipping_city'] as String? ?? '',
      shippingCountry: json['shipping_country'] as String? ?? '',
      shippingPostalCode: json['shipping_postal_code'] as String? ?? '',
      note: json['note'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      shippingCarrier: json['shipping_carrier'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      confirmedAt: parseDate(json['confirmed_at']),
      paidAt: parseDate(json['paid_at']),
      shippedAt: parseDate(json['shipped_at']),
      deliveredAt: parseDate(json['delivered_at']),
      cancelledAt: parseDate(json['cancelled_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List)
          .map((e) => OrderDetailItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
