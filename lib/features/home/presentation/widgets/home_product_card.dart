import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';

class HomeProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onBuyTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const HomeProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onBuyTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.watch,
                          size: 48,
                          color: AppColors.greyLight,
                        ),
                      ),
                    ),
                  ),
                  if (product.displaySalePercent != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.displaySalePercent}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: product.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  height: 1.3,
                                ),
                              ),
                              if (product.isPreOrder)
                                const TextSpan(
                                  text: ' - Nhận Order',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    height: 1.3,
                                  ),
                                ),
                              if (product.sku != null && product.sku!.isNotEmpty)
                                TextSpan(
                                  text: '  #${product.sku}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                    height: 1.3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PriceFormatter.formatJPY(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.originalPrice != null &&
                            product.originalPrice! > product.price) ...[
                          const SizedBox(height: 2),
                          Text(
                            PriceFormatter.formatJPY(product.originalPrice!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Buy button + Favorite
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: onBuyTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.black,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              child: const Text(
                                'Mua',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 26,
                              color: isFavorite
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}