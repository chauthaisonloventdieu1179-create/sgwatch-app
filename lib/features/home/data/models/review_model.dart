class ReviewModel {
  final int id;
  final int productId;
  final int rating;
  final String? title;
  final String? comment;
  final List<String> imageUrls;
  final bool isApproved;
  final bool isOwner;
  final String userName;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.rating,
    this.title,
    this.comment,
    required this.imageUrls,
    required this.isApproved,
    required this.isOwner,
    required this.userName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final firstName = user?['first_name']?.toString() ?? '';
    final lastName = user?['last_name']?.toString() ?? '';
    final name = '$firstName $lastName'.trim();

    final baseUrl = json['image_base_url']?.toString() ?? '';
    final rawUrls = (json['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final fullImageUrls = rawUrls.map((path) {
      if (path.startsWith('http')) return path;
      return '$baseUrl$path';
    }).toList();

    return ReviewModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      rating: json['rating'] as int? ?? 5,
      title: json['title']?.toString(),
      comment: json['comment']?.toString(),
      imageUrls: fullImageUrls,
      isApproved: json['is_approved'] as bool? ?? false,
      isOwner: json['is_owner'] as bool? ?? false,
      userName: name.isNotEmpty ? name : 'Ẩn danh',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ReviewPagination {
  final int currentPage;
  final int lastPage;
  final int total;

  const ReviewPagination({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory ReviewPagination.fromJson(Map<String, dynamic> json) {
    return ReviewPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}
