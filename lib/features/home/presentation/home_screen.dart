import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/home/presentation/home_viewmodel.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_banner_slider.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_brand_grid.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_header.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_grid.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_horizontal_list.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/home/catalog/product_list_screen.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_screen.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_section_header.dart';
import 'package:sgwatch_app/features/big_sale/presentation/big_sale_list_screen.dart';
import 'package:sgwatch_app/features/guide/presentation/guide_screen.dart';
import 'package:sgwatch_app/features/home/presentation/banner_webview_screen.dart';
import 'package:sgwatch_app/features/home/presentation/blog_list_screen.dart';
import 'package:sgwatch_app/features/store_info/presentation/store_info_screen.dart';
import 'package:sgwatch_app/features/about/presentation/about_screen.dart';
import 'package:sgwatch_app/features/refund_policy/presentation/refund_policy_screen.dart';
import 'package:sgwatch_app/features/warranty/presentation/warranty_policy_screen.dart';
import 'package:sgwatch_app/features/warranty/presentation/laptop_warranty_screen.dart';
import 'package:sgwatch_app/features/guide/presentation/watch_size_guide_screen.dart';
import 'package:sgwatch_app/features/buyback_policy/presentation/buyback_policy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  final _favoriteVM = FavoriteViewModel();
  final _cartVM = CartViewModel();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _favoriteVM.addListener(_onViewModelChanged);
    _cartVM.addListener(_onViewModelChanged);
    _viewModel.loadHomeData();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onBuyTap(product) async {
    if (product.isCarnival == true) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          groupedProducts: product.groupedProducts,
        ),
      ));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _cartVM.addToCart(product.id);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CartScreen()))
          .then((_) => _viewModel.refreshBanners());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thêm vào giỏ hàng.')),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _favoriteVM.removeListener(_onViewModelChanged);
    _cartVM.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLightBlue,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Fixed header
          HomeHeader(
            cartItemCount: _viewModel.cartItemCount,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            onSearchSubmit: (query) {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => ProductListScreen(searchQuery: query),
                  ))
                  .then((_) => _viewModel.refreshBanners());
            },
            onCartTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const CartScreen()))
                  .then((_) => _viewModel.refreshBanners());
            },
          ),
          // Scrollable content
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
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
              onPressed: () => _viewModel.loadHomeData(),
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait([
          _viewModel.refreshBanners(),
          _viewModel.refreshFeaturedProducts(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 0. Quick action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickButton(
                      label: 'BIG SALE',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const BigSaleListScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickButton(
                      label: 'HƯỚNG DẪN',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const GuideScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickButton(
                      label: 'CỬA HÀNG',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const StoreInfoScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickButton(
                      label: 'BLOG',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const BlogListScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 1. Banner slider
            HomeBannerSlider(
              banners: _viewModel.banners,
              onPageChanged: _viewModel.setBannerIndex,
              onBannerTap: (banner) {
                final link = banner.link;
                if (link != null && link.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BannerWebViewScreen(url: link),
                  ));
                }
              },
            ),
            const SizedBox(height: 10),

            // 2. Brand grid
            HomeBrandGrid(
              brands: _viewModel.brands,
              onBrandTap: (brand) {
                debugPrint('[BrandTap] id=${brand.id} name="${brand.name}" isSpecial=${brand.isSpecialFilter}');
                if (brand.isSpecialFilter) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => ProductListScreen(
                          title: brand.name,
                          initialGender: brand.filterGender,
                          initialStockType: brand.filterStockType,
                          categoryId: brand.filterCategoryId ?? 1,
                          isDomestic: brand.filterIsDomestic,
                          isNew: brand.filterIsNew,
                          initialSortBy: 'display_order',
                        ),
                      ))
                      .then((_) => _viewModel.refreshBanners());
                } else {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => ProductListScreen(
                          title: brand.name,
                          brandId: brand.id,
                          categoryId: 1,
                          initialSortBy: 'display_order',
                          groupBy: brand.id == 5 ? 'name' : null,
                        ),
                      ))
                      .then((_) => _viewModel.refreshBanners());
                }
              },
            ),
            const SizedBox(height: 20),

            // 4a. Collections section
            if (_viewModel.collections.isNotEmpty) ...[
              for (final collection in _viewModel.collections) ...[
                HomeSectionHeader(
                  title: 'BST Đồng hồ nội địa bán chạy 2026',
                  fontSize: 14,
                ),
                const SizedBox(height: 15),
                HomeProductHorizontalList(
                  products: collection.products,
                  favoriteViewModel: _favoriteVM,
                  // 2 card đầy + card thứ 3 lấp ló ~5px
                  cardWidth: (MediaQuery.of(context).size.width - 16 * 2 - 12 - 5) / 2,
                  onProductTap: (product) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ))
                        .then((_) => _viewModel.refreshBanners());
                  },
                  onBuyTap: (product) => _onBuyTap(product),
                ),
                const SizedBox(height: 24),
              ],
            ],

            // 4. Watch products section
            const HomeSectionHeader(
              title: 'Đồng hồ nổi bật',
            ),
            const SizedBox(height: 15),
            HomeProductGrid(
              products: _viewModel.featuredProducts,
              favoriteViewModel: _favoriteVM,
              onProductTap: (product) {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
              onBuyTap: (product) => _onBuyTap(product),
            ),
            const SizedBox(height: 24),

            // 5. Laptop section
            HomeSectionHeader(
              title: 'Laptop',
              actionText: 'Xem thêm',
              onActionTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const ProductListScreen(
                        title: 'Laptop',
                        categoryId: 2,
                      ),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
            ),
            const SizedBox(height: 15),
            HomeProductGrid(
              products: _viewModel.laptops,
              favoriteViewModel: _favoriteVM,
              onProductTap: (product) {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
              onBuyTap: (product) => _onBuyTap(product),
            ),
            const SizedBox(height: 24),

            // 6. Macbook section
            HomeSectionHeader(
              title: 'Macbook',
              actionText: 'Xem thêm',
              onActionTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const ProductListScreen(
                        title: 'Macbook',
                        categoryId: 3,
                      ),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
            ),
            const SizedBox(height: 15),
            HomeProductGrid(
              products: _viewModel.macbooks,
              favoriteViewModel: _favoriteVM,
              onProductTap: (product) {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
              onBuyTap: (product) => _onBuyTap(product),
            ),
            const SizedBox(height: 24),

            // 7. iPad section
            HomeSectionHeader(
              title: 'iPad',
              actionText: 'Xem thêm',
              onActionTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const ProductListScreen(
                        title: 'iPad',
                        categoryId: 4,
                      ),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
            ),
            const SizedBox(height: 15),
            HomeProductGrid(
              products: _viewModel.ipads,
              favoriteViewModel: _favoriteVM,
              onProductTap: (product) {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ))
                    .then((_) => _viewModel.refreshBanners());
              },
              onBuyTap: (product) => _onBuyTap(product),
            ),
            const SizedBox(height: 24),

            // 8. Đồng hồ cũ section (commented out)
            // HomeSectionHeader(
            //   title: 'Đồng hồ cũ',
            //   actionText: 'Xem thêm',
            //   onActionTap: () {
            //     Navigator.of(context)
            //         .push(MaterialPageRoute(
            //           builder: (_) => const ProductListScreen(
            //             title: 'Đồng hồ cũ',
            //             categoryId: 1,
            //             isNew: 0,
            //           ),
            //         ))
            //         .then((_) => _viewModel.refreshBanners());
            //   },
            // ),
            // const SizedBox(height: 15),
            // HomeProductHorizontalList(
            //   products: _viewModel.usedWatches,
            //   onProductTap: (product) {
            //     Navigator.of(context)
            //         .push(MaterialPageRoute(
            //           builder: (_) => ProductDetailScreen(product: product),
            //         ))
            //         .then((_) => _viewModel.refreshBanners());
            //   },
            //   onBuyTap: (product) => _onBuyTap(product),
            // ),
            // const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: const Text(
                'SGWATCH',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context,
              icon: Icons.info_outline,
              label: 'Về chúng tôi',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AboutScreen()));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.watch_outlined,
              label: 'Chính sách bảo hành đồng hồ',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const WarrantyPolicyScreen()));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.laptop_outlined,
              label: 'Chính sách bảo hành laptop',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LaptopWarrantyScreen()));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.assignment_return_outlined,
              label: 'Chính sách hoàn tiền',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const RefundPolicyScreen()));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.watch_outlined,
              label: 'Hướng dẫn chọn đồng hồ',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const WatchSizeGuideScreen()));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.recycling,
              label: 'Chính sách thu mua lại',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BuybackPolicyScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.black),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.greyLight),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
