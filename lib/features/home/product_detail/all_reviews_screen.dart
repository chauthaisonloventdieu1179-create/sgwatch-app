import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/features/home/data/models/review_model.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_viewmodel.dart';
import 'package:sgwatch_app/features/home/product_detail/write_review_screen.dart';

class AllReviewsScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final double averageRating;
  final int reviewCount;
  final bool isPurchased;
  final ProductDetailViewModel viewModel;

  const AllReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.reviewCount,
    required this.isPurchased,
    required this.viewModel,
  });

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  int? _selectedRating; // null = all

  List<ReviewModel> get _filteredReviews {
    final reviews = widget.viewModel.reviews;
    if (_selectedRating == null) return reviews;
    return reviews.where((r) => r.rating == _selectedRating).toList();
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tất cả đánh giá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Star filter tabs
          _buildStarFilter(),
          // Reviews list
          Expanded(
            child: _filteredReviews.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có đánh giá',
                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredReviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(_filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isPurchased
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _onWriteReview,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(
                      'Viết đánh giá',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStarFilter() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(null, 'Tất cả'),
            const SizedBox(width: 8),
            ...List.generate(5, (i) {
              final star = 5 - i;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(star, null),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int? rating, String? label) {
    final isSelected = _selectedRating == rating;
    return GestureDetector(
      onTap: () => setState(() => _selectedRating = rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rating != null) ...[
              Icon(Icons.star,
                  size: 16,
                  color: isSelected ? AppColors.white : Colors.amber),
              const SizedBox(width: 4),
            ],
            Text(
              label ?? '$rating',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info + rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.greyLight,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (review.isOwner)
                GestureDetector(
                  onTap: () => _confirmDelete(review),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Date
          Text(
            DateFormatter.formatDateTime(review.createdAt),
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
          ),
          // Title
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
          ],
          // Images
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = review.imageUrls[index];
                  return GestureDetector(
                    onTap: () => _showFullImage(url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.greyLight,
                          child: const Icon(Icons.broken_image,
                              color: AppColors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          // Show reply count
          if (review.imageUrls.isNotEmpty || review.comment != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Hiển thị 1 phản hồi',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ReviewModel review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await widget.viewModel.deleteReview(review.id);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa đánh giá.')),
        );
      }
    }
  }

  Future<void> _onWriteReview() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(
          productId: widget.productId,
          productName: widget.productName,
          viewModel: widget.viewModel,
        ),
      ),
    );
    if (result == true) {
      widget.viewModel.reloadReviews();
    }
  }
}
