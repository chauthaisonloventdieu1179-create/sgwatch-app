import 'dart:async';

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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final step = (widget.cardWidth ?? 170) + 12; // card + separator

      if (current + step >= max) {
        // Về đầu danh sách
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.animateTo(
          current + step,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
