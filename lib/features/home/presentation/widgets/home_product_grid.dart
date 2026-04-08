import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';

class HomeProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onBuyTap;
  final FavoriteViewModel favoriteViewModel;

  const HomeProductGrid({
    super.key,
    required this.products,
    required this.favoriteViewModel,
    this.onProductTap,
    this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.495,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return HomeProductCard(
            product: product,
            isFavorite: favoriteViewModel.isFavorite(product.id),
            onTap: () => onProductTap?.call(product),
            onBuyTap: () => onBuyTap?.call(product),
            onFavoriteTap: () => favoriteViewModel.toggle(product),
          );
        },
      ),
    );
  }
}