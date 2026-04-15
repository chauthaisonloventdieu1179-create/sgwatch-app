int _parseInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class AdminOrderModel {
  final int id;
  final String orderNumber;
  final String orderType;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? paymentReceipt;
  final String shippingMethod;
  final int subtotal;
  final int shippingFee;
  final int codFee;
  final int stripeFee;
  final int totalAmount;
  final String currency;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final String? shippingCity;
  final String shippingCountry;
  final String? shippingPostalCode;
  final String? note;
  final String? trackingNumber;
  final String? shippingCarrier;
  final String? cancelReason;
  final String? adminNote;
  final DateTime? confirmedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final List<AdminOrderItemModel> items;
  final AdminOrderUserModel? user;

  const AdminOrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.paymentReceipt,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.codFee,
    required this.stripeFee,
    required this.totalAmount,
    required this.currency,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    this.shippingCity,
    required this.shippingCountry,
    this.shippingPostalCode,
    this.note,
    this.trackingNumber,
    this.shippingCarrier,
    this.cancelReason,
    this.adminNote,
    this.confirmedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.createdAt,
    required this.items,
    this.user,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return AdminOrderModel(
      id: _parseInt(json['id']),
      orderNumber: json['order_number']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentReceipt: json['payment_receipt']?.toString(),
      shippingMethod: json['shipping_method']?.toString() ?? '',
      subtotal: _parseInt(json['subtotal']),
      shippingFee: _parseInt(json['shipping_fee']),
      codFee: _parseInt(json['cod_fee']),
      stripeFee: _parseInt(json['stripe_fee']),
      totalAmount: _parseInt(json['total_amount']),
      currency: json['currency']?.toString() ?? 'JPY',
      shippingName: json['shipping_name']?.toString() ?? '',
      shippingPhone: json['shipping_phone']?.toString() ?? '',
      shippingAddress: json['shipping_address']?.toString() ?? '',
      shippingCity: json['shipping_city']?.toString(),
      shippingCountry: json['shipping_country']?.toString() ?? '',
      shippingPostalCode: json['shipping_postal_code']?.toString(),
      note: json['note']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      shippingCarrier: json['shipping_carrier']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      adminNote: json['admin_note']?.toString(),
      confirmedAt: parseDate(json['confirmed_at']),
      paidAt: parseDate(json['paid_at']),
      shippedAt: parseDate(json['shipped_at']),
      deliveredAt: parseDate(json['delivered_at']),
      cancelledAt: parseDate(json['cancelled_at']),
      createdAt: DateTime.parse(json['created_at'].toString()),
      items: (json['items'] as List? ?? [])
          .map((e) => AdminOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] != null
          ? AdminOrderUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'waiting_order':
        return 'Chờ đặt hàng';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'refunded':
        return 'Hoàn tiền';
      default:
        return status;
    }
  }
}

class AdminOrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productSku;
  final String? productImage;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  const AdminOrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory AdminOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderItemModel(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      productSku: json['product_sku']?.toString(),
      productImage: json['product_image']?.toString(),
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseInt(json['unit_price']),
      totalPrice: _parseInt(json['total_price']),
    );
  }
}

class AdminOrderUserModel {
  final int id;
  final String fullName;
  final String email;

  const AdminOrderUserModel({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory AdminOrderUserModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderUserModel(
      id: _parseInt(json['id']),
      fullName: json['full_name']?.toString() ??
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email']?.toString() ?? '',
    );
  }
}
