import 'package:flutter/material.dart';
import 'package:sgwatch_app/app/config/env.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/chat/presentation/chat_screen.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/data/models/review_model.dart';
import 'package:sgwatch_app/features/home/product_detail/all_reviews_screen.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_viewmodel.dart';
import 'package:sgwatch_app/features/home/product_detail/write_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailViewModel _viewModel;
  final _favoriteVM = FavoriteViewModel();
  final _cartVM = CartViewModel();
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductDetailViewModel(widget.product);
    _viewModel.addListener(_onChanged);
    _favoriteVM.addListener(_onChanged);
    _viewModel.loadProductDetail();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _favoriteVM.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onBuyTap() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _cartVM.addToCart(_viewModel.product.id);

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    if (success) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cartVM.error ?? 'Không thể thêm vào giỏ hàng.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildAppBar(context),
          if (_viewModel.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            Expanded(
              child: SelectionArea(
                child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSlider(),
                    _buildProductInfo(),
                    const SizedBox(height: 10),
                    if (_viewModel.productInfo != null) _buildProductInfoBox(),
                    if (_viewModel.productInfo != null)
                      const SizedBox(height: 10),
                    if (_viewModel.dealInfo != null) _buildDealBox(),
                    if (_viewModel.dealInfo != null) const SizedBox(height: 10),
                    if (_viewModel.description != null) _buildDescriptionBox(),
                    if (_viewModel.description != null)
                      const SizedBox(height: 10),
                    if (_viewModel.shortDescription != null &&
                        _viewModel.shortDescription!.isNotEmpty)
                      _buildShortDescriptionBox(),
                    if (_viewModel.shortDescription != null &&
                        _viewModel.shortDescription!.isNotEmpty)
                      const SizedBox(height: 10),
                    _buildSpecsTable(),
                    const SizedBox(height: 10),
                    _buildReviewSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: AppColors.black,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 24,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    if (_viewModel.images.isEmpty) {
      return const SizedBox(height: 300);
    }
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: _viewModel.images.length,
              onPageChanged: (i) => _viewModel.setImageIndex(i),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openFullScreenGallery(index),
                  child: Image.network(
                    _viewModel.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.watch,
                        size: 80,
                        color: AppColors.greyLight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_viewModel.images.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _viewModel.images.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _viewModel.currentImageIndex
                        ? AppColors.black
                        : AppColors.greyLight,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final p = _viewModel.product;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: p.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    height: 1.4,
                  ),
                ),
                if (p.isPreOrder)
                  const TextSpan(
                    text: ' - Nhận Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      height: 1.4,
                    ),
                  ),
                if (p.sku != null && p.sku!.isNotEmpty)
                  TextSpan(
                    text: '  #${p.sku}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (i) {
                final rating = p.averageRating ?? 0;
                return Icon(
                  i < rating.round() ? Icons.star : Icons.star_border,
                  size: 20,
                  color: i < rating.round()
                      ? Colors.amber
                      : AppColors.greyPlaceholder,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${p.reviewCount ?? 0} đánh giá',
                style: const TextStyle(fontSize: 15, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                PriceFormatter.formatJPY(p.price),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (p.displaySalePercent != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${p.displaySalePercent}%',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (p.stockQuantity != null)
                Text(
                  'Số lượng còn: ${p.stockQuantity}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
            ],
          ),
          if (p.originalPrice != null && p.originalPrice! > p.price) ...[
            const SizedBox(height: 4),
            Text(
              PriceFormatter.formatJPY(p.originalPrice!),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.red,
              ),
            ),
          ],
          if (p.priceVnd != null && p.priceVnd! > 0) ...[
            const SizedBox(height: 4),
            Text(
              PriceFormatter.formatVND(p.priceVnd!),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
          if (p.points != null && p.points! > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${p.points} point',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductInfoBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'THÔNG TIN SẢN PHẨM',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _viewModel.productInfo!,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.black,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'KHUYẾN MÃI',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _viewModel.dealInfo!,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.black,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _viewModel.description!,
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.black,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(
              _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortDescriptionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả ngắn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _viewModel.shortDescription!,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.black,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsTable() {
    if (_viewModel.visibleSpecs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông số kỷ thuật',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            border: TableBorder.all(color: AppColors.greyLight, width: 0.5),
            children: _viewModel.visibleSpecs.map((spec) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      spec[0],
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      spec[1],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (_viewModel.hasMoreSpecs && !_viewModel.isDescriptionExpanded) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _viewModel.expandDescription(),
              child: const Center(
                child: Text(
                  'Xem thêm...',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    final rating = _viewModel.product.averageRating ?? 0;
    final reviewCount = _viewModel.product.reviewCount ?? 0;
    final reviews = _viewModel.reviews;

    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AllReviewsScreen(
                        productId: _viewModel.product.id,
                        productName: _viewModel.product.name,
                        averageRating: rating.toDouble(),
                        reviewCount: reviewCount,
                        isPurchased: _viewModel.isPurchased,
                        viewModel: _viewModel,
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Tất cả đánh giá',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 30, color: Colors.amber),
              const Spacer(),
              Text(
                '$reviewCount đánh giá',
                style: const TextStyle(fontSize: 15, color: AppColors.grey),
              ),
            ],
          ),
          // Reviews list (show max 2)
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.greyLight),
            ...reviews.take(2).map((r) => _buildReviewItem(r)),
          ],
          // Write review button
          if (_viewModel.isPurchased) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => WriteReviewScreen(
                        productId: _viewModel.product.id,
                        productName: _viewModel.product.name,
                        viewModel: _viewModel,
                      ),
                    ),
                  );
                  if (result == true) {
                    _viewModel.reloadReviews();
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Viết đánh giá'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User + rating
          Row(
            children: [
              CircleAvatar(
                radius: 18,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              Text(
                DateFormatter.formatDateTime(review.createdAt),
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
              ),
            ],
          ),
          // Title
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title!,
              style: const TextStyle(
                fontSize: 15,
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
                fontSize: 15,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
          ],
          // Images
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = _buildImageUrl(review.imageUrls[index]);
                  return GestureDetector(
                    onTap: () => _showFullImage(url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.greyLight,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openFullScreenGallery(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenGallery(
          images: _viewModel.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  String _buildImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${Env.baseURL}/storage/$path';
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 15,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Favorite button
            GestureDetector(
              onTap: () => _favoriteVM.toggle(_viewModel.product),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _favoriteVM.isFavorite(_viewModel.product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 31,
                  color: _favoriteVM.isFavorite(_viewModel.product.id)
                      ? AppColors.primary
                      : AppColors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Chat button
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      productImageUrl: _viewModel.product.imageUrl,
                      productText:
                          'Tôi đang quan tâm đến sản phẩm ${_viewModel.product.name}',
                    ),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: const Icon(
                  Icons.chat_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _onBuyTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                  ),
                  child: const Text(
                    'Mua ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: AppColors.greyLight,
                    ),
                  ),
                ),
              );
            },
          ),
          // Close button
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
          // Page indicator
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
