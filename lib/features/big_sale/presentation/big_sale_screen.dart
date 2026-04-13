import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/big_sale/presentation/big_sale_viewmodel.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_screen.dart';

class BigSaleScreen extends StatefulWidget {
  final int id;

  const BigSaleScreen({super.key, required this.id});

  @override
  State<BigSaleScreen> createState() => _BigSaleScreenState();
}

class _BigSaleScreenState extends State<BigSaleScreen> {
  final _viewModel = BigSaleViewModel();
  final _favoriteVM = FavoriteViewModel();
  final _cartVM = CartViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _favoriteVM.addListener(_onChanged);
    _cartVM.addListener(_onChanged);
    _viewModel.loadBigSale(widget.id);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onBuyTap(product) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final success = await _cartVM.addToCart(product.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thêm vào giỏ hàng.')),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _favoriteVM.removeListener(_onChanged);
    _cartVM.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _viewModel.bigSale?.title ?? 'BIG SALE',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _viewModel.error!,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _viewModel.loadBigSale(widget.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final bigSale = _viewModel.bigSale;
    if (bigSale == null) {
      return const Center(
        child: Text(
          'Không có chương trình khuyến mãi.',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image
          if (bigSale.mediaUrl != null && bigSale.mediaUrl!.isNotEmpty)
            Image.network(
              bigSale.mediaUrl!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 220,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Center(
                  child: Icon(Icons.local_offer, size: 48, color: AppColors.primary),
                ),
              ),
            ),

          // Description
          if (bigSale.description != null && bigSale.description!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bigSale.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bigSale.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                  ),
                  if (bigSale.saleStartDate != null && bigSale.saleEndDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Từ ${bigSale.saleStartDate} đến ${bigSale.saleEndDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Products header
          if (bigSale.products.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sản phẩm khuyến mãi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Product grid (same card as home)
          if (bigSale.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.495,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: bigSale.products.length,
                itemBuilder: (context, index) {
                  final product = bigSale.products[index];
                  return HomeProductCard(
                    product: product,
                    isFavorite: _favoriteVM.isFavorite(product.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    onBuyTap: () => _onBuyTap(product),
                    onFavoriteTap: () => _favoriteVM.toggle(product),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}