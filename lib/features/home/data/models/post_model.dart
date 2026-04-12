class PostModel {
  final int id;
  final String title;
  final String? description;
  final String? link;
  final String? mediaUrl;
  final bool isActive;
  final int sortOrder;

  const PostModel({
    required this.id,
    required this.title,
    this.description,
    this.link,
    this.mediaUrl,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      link: json['link']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
