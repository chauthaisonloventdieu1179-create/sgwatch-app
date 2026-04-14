import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/catalog/filter_bottom_sheet.dart';
import 'package:sgwatch_app/features/home/catalog/product_list_viewmodel.dart';
import 'package:sgwatch_app/features/home/data/models/product_model.dart';
import 'package:sgwatch_app/features/home/presentation/home_viewmodel.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_screen.dart';
import 'package:sgwatch_app/core/widgets/shimmer_product_grid.dart';

class ProductListScreen extends StatefulWidget {
  final String? title;
  final String? categorySlug;
  final int? categoryId;
  final int? brandId;
  final String? searchQuery;
  final String? initialGender;
  final String? initialStockType;
  final int? isDomestic;
  final int? isNew;
  final String initialSortBy;
  final String? groupBy;

  const ProductListScreen({
    super.key,
    this.title,
    this.categorySlug,
    this.categoryId,
    this.brandId,
    this.searchQuery,
    this.initialGender,
    this.initialStockType,
    this.isDomestic,
    this.isNew,
    this.initialSortBy = 'newest',
    this.groupBy,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductListViewModel _viewModel;
  final _favoriteVM = FavoriteViewModel();
  final _cartVM = CartViewModel();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const _sortOptions = [
    _SortOption(value: 'display_order', icon: Icons.sort, label: 'Mặc định'),
    _SortOption(value: 'newest', icon: Icons.schedule, label: 'Mới nhất'),
    _SortOption(
        value: 'price_asc', icon: Icons.trending_up, label: 'Giá thấp dần'),
    _SortOption(
        value: 'price_desc', icon: Icons.trending_down, label: 'Giá cao dần'),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ProductListViewModel(
      categorySlug: widget.categorySlug,
      categoryId: widget.categoryId,
      brandId: widget.brandId,
      initialKeyword: widget.searchQuery,
      initialGender: widget.initialGender,
      initialStockType: widget.initialStockType,
      isDomestic: widget.isDomestic,
      isNew: widget.isNew,
      sortBy: widget.initialSortBy,
      groupBy: widget.groupBy,
    );
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
    }
    _viewModel.addListener(_onChanged);
    _favoriteVM.addListener(_onChanged);
    _scrollController.addListener(_onScroll);
    _viewModel.loadProducts();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.maxScrollExtent > 0 &&
        pos.pixels >= pos.maxScrollExtent * 0.5) {
      _viewModel.loadMore();
    }
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

  void _openFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        brands: HomeViewModel.cachedFilterBrands,
        selectedCategoryId: _viewModel.filterCategoryId,
        selectedBrandId: _viewModel.filterBrandId,
        selectedGender: _viewModel.filterGender,
        selectedMovementType: _viewModel.filterMovementType,
        selectedStockType: _viewModel.filterStockType,
        selectedIsNew: _viewModel.filterIsNew,
      ),
    );

    if (result != null && mounted) {
      _viewModel.applyFilter(result);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _viewModel.removeListener(_onChanged);
    _favoriteVM.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightBlue,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Back + Search bar + Cart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 30,
                    height: 44,
                    child: Icon(Icons.arrow_back_ios,
                        size: 20, color: AppColors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.greyLight),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 24, color: AppColors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm',
                              hintStyle:
                                  TextStyle(fontSize: 16, color: AppColors.grey),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.black),
                            textInputAction: TextInputAction.search,
                            onChanged: (v) => _viewModel.setKeyword(v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: const Icon(Icons.shopping_cart_outlined,
                      size: 26, color: AppColors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Filter + Sort chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Clear filters
                if (_viewModel.filterCount > 0)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _viewModel.clearFilters();
                    },
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child:
                          Icon(Icons.close, size: 20, color: AppColors.black),
                    ),
                  ),
                if (_viewModel.filterCount > 0) const SizedBox(width: 6),
                // Filter button
                GestureDetector(
                  onTap: _openFilter,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _viewModel.filterCount > 0
                          ? AppColors.black
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _viewModel.filterCount > 0
                            ? AppColors.black
                            : AppColors.greyLight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list,
                            size: 20,
                            color: _viewModel.filterCount > 0
                                ? AppColors.white
                                : AppColors.black),
                        const SizedBox(width: 6),
                        Text(
                          'Lọc${_viewModel.filterCount > 0 ? ' (${_viewModel.filterCount})' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _viewModel.filterCount > 0
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Sort chips
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sortOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final option = _sortOptions[index];
                        final isSelected = _viewModel.sortBy == option.value;
                        return GestureDetector(
                          onTap: () => _viewModel.setSortBy(option.value),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.black
                                    : AppColors.greyLight,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 4,
                                  offset: Offset(1, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(option.icon,
                                    size: 16,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.black),
                                const SizedBox(width: 4),
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerProductGrid(
          itemCount: 6,
          childAspectRatio: 178 / 301,
        ),
      );
    }

    if (_viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_viewModel.error!,
                style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _viewModel.loadProducts(),
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

    if (_viewModel.products.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy sản phẩm',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _viewModel.products[index];
                return HomeProductCard(
                  product: product,
                  isFavorite: _favoriteVM.isFavorite(product.id),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: product,
                          groupedProducts: product.groupedProducts,
                        ),
                      ),
                    );
                  },
                  onBuyTap: () => _onBuyTap(product),
                  onFavoriteTap: () => _favoriteVM.toggle(product),
                  groupedProducts: product.groupedProducts,
                  onGroupedTap: (grouped) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: grouped.toProductModel(),
                          groupedProducts: product.groupedProducts,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: _viewModel.products.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.495,
            ),
          ),
        ),
        if (_viewModel.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

}

class _SortOption {
  final String value;
  final IconData icon;
  final String label;
  const _SortOption(
      {required this.value, required this.icon, required this.label});
}