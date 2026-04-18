import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';

class HomeProductHorizontalList extends StatefulWidget {
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
  State<HomeProductHorizontalList> createState() =>
      _HomeProductHorizontalListState();
}

class _HomeProductHorizontalListState
    extends State<HomeProductHorizontalList> {
  late final ScrollController _scrollController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  Future<void> _startAutoScroll() async {
    // Chờ widget render xong và data sẵn sàng
    await Future.delayed(const Duration(seconds: 4));

    while (!_disposed && mounted) {
      if (_scrollController.hasClients) {
        final pos = _scrollController.position;
        if (pos.maxScrollExtent > 0) {
          final current = pos.pixels;
          final step = (widget.cardWidth ?? 170) + 12;
          final goBack = current + step >= pos.maxScrollExtent;
          try {
            await _scrollController.animateTo(
              goBack ? 0 : current + step,
              duration: Duration(milliseconds: goBack ? 800 : 600),
              curve: Curves.easeInOut,
            );
          } catch (_) {}
        }
      }

      if (_disposed || !mounted) break;
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final double itemWidth = widget.cardWidth ?? 170;

    return SizedBox(
      height: 340,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return SizedBox(
            width: itemWidth,
            child: HomeProductCard(
              product: product,
              isFavorite: widget.favoriteViewModel.isFavorite(product.id),
              onTap: () => widget.onProductTap?.call(product),
              onBuyTap: () => widget.onBuyTap?.call(product),
              onFavoriteTap: () => widget.favoriteViewModel.toggle(product),
            ),
          );
        },
      ),
    );
  }
}
