import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/home/data/models/brand_model.dart';

class HomeBrandGrid extends StatelessWidget {
  final List<BrandModel> brands;
  final ValueChanged<BrandModel>? onBrandTap;

  const HomeBrandGrid({
    super.key,
    required this.brands,
    this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          return _BrandItem(
            brand: brands[index],
            onTap: () => onBrandTap?.call(brands[index]),
          );
        },
      ),
    );
  }
}

class _BrandItem extends StatelessWidget {
  final BrandModel brand;
  final VoidCallback? onTap;

  const _BrandItem({required this.brand, this.onTap});

  @override
  Widget build(BuildContext context) {
    final assetPath = brand.localAssetPath;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyLight, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Expanded(
              child: Padding(
                padding: brand.id == 3
                    ? const EdgeInsets.fromLTRB(2, 4, 2, 2)
                    : const EdgeInsets.fromLTRB(6, 8, 6, 4),
                child: assetPath != null
                    ? Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildTextFallback(),
                      )
                    : _buildTextFallback(),
              ),
            ),
            // Name
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: Text(
                brand.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFallback() {
    return Center(
      child: Text(
        brand.name,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
