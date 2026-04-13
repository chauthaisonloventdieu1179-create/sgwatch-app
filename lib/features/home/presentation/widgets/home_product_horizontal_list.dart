import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';

class HomeProductHorizontalList extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onBuyTap;
  final FavoriteViewModel favoriteViewModel;
  final double? cardWidth;

  const HomeProductHorizontalList({
    super.key,
    required this.products,
    required this.favoriteViewModel,
    this.onProductTap,
    this.onBuyTap,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    // cardWidth từ ngoài truyền vào hoặc mặc định 170
    final double itemWidth = cardWidth ??
        170;

    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: itemWidth,
            child: HomeProductCard(
              product: product,
              isFavorite: favoriteViewModel.isFavorite(product.id),
              onTap: () => onProductTap?.call(product),
              onBuyTap: () => onBuyTap?.call(product),
              onFavoriteTap: () => favoriteViewModel.toggle(product),
            ),
          );
        },
      ),
    );
  }
}
