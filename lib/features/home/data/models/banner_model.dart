class BannerModel {
  final int id;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  bool get isVideo {
    final lower = imageUrl.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm');
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imageUrl: (json['media_url'] ?? json['image_url'])?.toString() ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
