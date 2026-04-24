class AdminBlogPostModel {
  final int id;
  final String title;
  final String? description;
  final String? link;
  final String? mediaUrl;
  final bool isActive;

  const AdminBlogPostModel({
    required this.id,
    required this.title,
    this.description,
    this.link,
    this.mediaUrl,
    required this.isActive,
  });

  factory AdminBlogPostModel.fromJson(Map<String, dynamic> json) {
    return AdminBlogPostModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      link: json['link']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}
