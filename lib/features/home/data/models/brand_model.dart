class BrandModel {
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;
  final bool isComingSoon;

  /// Navigation params — used for special items (non-brand filters)
  final String? filterGender;
  final String? filterStockType;
  final int? filterCategoryId;
  final int? filterIsDomestic;
  final int? filterIsNew;

  const BrandModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.logoUrl,
    this.isComingSoon = false,
    this.filterGender,
    this.filterStockType,
    this.filterCategoryId,
    this.filterIsDomestic,
    this.filterIsNew,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }

  /// Whether this item uses special filter params instead of brand_id
  bool get isSpecialFilter =>
      filterGender != null ||
      filterStockType != null ||
      filterCategoryId != null ||
      filterIsDomestic != null ||
      filterIsNew != null;

  /// Local asset logo path mapped by brand id.
  String? get localAssetPath {
    const map = <int, String>{
      1: 'assets/images/orient-star-logo.png', // Orient Star
      2: 'assets/images/orient-log.png', // Orient
      3: 'assets/images/citizen-logo.png',
      4: 'assets/images/seiko-logo.png',
      5: 'assets/images/carnival-logo.png',
      6: 'assets/images/longines-logo.png',
      7: 'assets/images/tissot-logo.png',
      // 8: 'assets/images/omega-logo.png', // Omega removed
      11: 'assets/images/donghokhac-logo.png', // Đồng hồ khác
      // Row 1 special items
      -10: 'assets/images/male-logo.png',       // Đồng hồ nữ
      -11: 'assets/images/couple-logo.png',     // Đồng hồ cặp đôi
      -12: 'assets/images/donghoorder-logo.png',
      -13: 'assets/images/noidia-logo.png',     // Đồng hồ nội địa
      // Row 2 items
      -20: 'assets/images/laptop-logo.jpg',
      -21: 'assets/images/mackbook.webp',
      -22: 'assets/images/ipad.jpg',
      -23: 'assets/images/donghocu-logo.png',   // Đồng hồ cũ
    };
    return map[id];
  }
}
