import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_screen.dart';
import 'package:sgwatch_app/core/widgets/shimmer_product_grid.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriteVM = FavoriteViewModel();
  final _cartVM = CartViewModel();

  @override
  void initState() {
    super.initState();
    _favoriteVM.addListener(_onChanged);
    _favoriteVM.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onBuyTap(ProductModel product) async {
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
    _favoriteVM.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoriteVM.favorites;

    return Scaffold(
      backgroundColor: AppColors.backgroundLightBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sản phẩm yêu thích',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _favoriteVM.isLoading
                    ? const ShimmerProductGrid(
                        itemCount: 4,
                        childAspectRatio: 178 / 301,
                      )
                    : favorites.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có sản phẩm yêu thích',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.48,
                            ),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final product = favorites[index];
                              return HomeProductCard(
                                product: product,
                                isFavorite: true,
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
            ],
          ),
        ),
      ),
    );
  }

}
