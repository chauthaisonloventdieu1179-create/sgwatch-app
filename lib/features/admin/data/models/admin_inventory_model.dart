int _parseInventoryInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class AdminInventoryModel {
  final int id;
  final String type; // 'export' | 'import'
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String referenceType;
  final int? referenceId;
  final String? note;
  final DateTime createdAt;
  final AdminInventoryProductModel product;

  const AdminInventoryModel({
    required this.id,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.referenceType,
    this.referenceId,
    this.note,
    required this.createdAt,
    required this.product,
  });

  factory AdminInventoryModel.fromJson(Map<String, dynamic> json) {
    return AdminInventoryModel(
      id: _parseInventoryInt(json['id']),
      type: json['type']?.toString() ?? '',
      quantity: _parseInventoryInt(json['quantity']),
      stockBefore: _parseInventoryInt(json['stock_before']),
      stockAfter: _parseInventoryInt(json['stock_after']),
      referenceType: json['reference_type']?.toString() ?? '',
      referenceId: json['reference_id'] != null
          ? _parseInventoryInt(json['reference_id'])
          : null,
      note: json['note']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      product: AdminInventoryProductModel.fromJson(
          json['product'] as Map<String, dynamic>),
    );
  }
}

class AdminInventoryProductModel {
  final int id;
  final String name;
  final String sku;
  final String? primaryImageUrl;

  const AdminInventoryProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.primaryImageUrl,
  });

  factory AdminInventoryProductModel.fromJson(Map<String, dynamic> json) {
    return AdminInventoryProductModel(
      id: _parseInventoryInt(json['id']),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      primaryImageUrl: json['primary_image_url']?.toString(),
    );
  }
}
