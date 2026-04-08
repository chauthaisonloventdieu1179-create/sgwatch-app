import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class CartItemModel {
  final int id;
  final int productId;
  final int quantity;
  final double priceAtAddition;
  final String currency;
  final double subtotal;
  final ProductModel? product;

  const CartItemModel({
    required this.id,
    required this.productId,
    this.quantity = 1,
    this.priceAtAddition = 0,
    this.currency = 'JPY',
    this.subtotal = 0,
    this.product,
  });

  String get name => product?.name ?? '';
  String get imageUrl => product?.imageUrl ?? '';
  double get displayPrice => product?.price ?? priceAtAddition;
  double get totalPrice => displayPrice * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      productId: productId,
      quantity: quantity ?? this.quantity,
      priceAtAddition: priceAtAddition,
      currency: currency,
      subtotal: subtotal,
      product: product,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    return CartItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int? ?? 1,
      priceAtAddition: _parseDouble(json['price_at_addition']),
      currency: json['currency']?.toString() ?? 'JPY',
      subtotal: _parseDouble(json['subtotal']),
      product: productJson != null ? ProductModel.fromJson(productJson) : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
