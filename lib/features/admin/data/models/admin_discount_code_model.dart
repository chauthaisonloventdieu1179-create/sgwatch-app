class DiscountCodeModel {
  final int id;
  final String code;
  final int quantity;
  final int amount;
  final bool isActive;
  final String? expiresAt;
  final String createdAt;

  const DiscountCodeModel({
    required this.id,
    required this.code,
    required this.quantity,
    required this.amount,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
  });

  factory DiscountCodeModel.fromJson(Map<String, dynamic> json) {
    return DiscountCodeModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      amount: json['amount'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      expiresAt: json['expires_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
