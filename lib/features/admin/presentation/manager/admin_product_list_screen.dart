import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_product_model.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_product_form_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const AdminProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<AdminProductListScreen> createState() =>
      _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final _ds = AdminDatasource(ApiClient());
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  List<AdminProductModel> _products = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _keyword;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      _loadMore();
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _products = [];
      _currentPage = 1;
      _hasMore = true;
    });
    try {
      final res = await _ds.getProducts(
        page: 1,
        categoryId: widget.categoryId,
        keyword: _keyword,
      );
      setState(() {
        _products = res.products;
        _hasMore = res.currentPage < res.lastPage;
        _currentPage = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    final nextPage = _currentPage + 1;
    setState(() => _isLoading = true);
    try {
      final res = await _ds.getProducts(
        page: nextPage,
        categoryId: widget.categoryId,
        keyword: _keyword,
      );
      setState(() {
        _products.addAll(res.products);
        _hasMore = res.currentPage < res.lastPage;
        _currentPage = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(AdminProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _ds.deleteProduct(product.id);
      setState(() => _products.removeWhere((p) => p.id == product.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi xóa sản phẩm')),
        );
      }
    }
  }

  void _onSearch(String value) {
    _keyword = value.trim().isEmpty ? null : value.trim();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminProductFormScreen(
                categoryId: widget.categoryId,
                categoryName: widget.categoryName,
              ),
            ),
          );
          _loadProducts();
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle:
                    const TextStyle(color: AppColors.grey, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundGrey,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _onSearch,
              onChanged: (v) => setState(() {}),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Không có sản phẩm',
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          if (index == _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return _buildProductCard(_products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(AdminProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: product.primaryImageUrl != null
                ? Image.network(
                    product.primaryImageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.sku != null) ...[
                    const SizedBox(height: 2),
                    Text('SKU: ${product.sku}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        PriceFormatter.formatJPY(
                            product.priceJpy.toDouble()),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      const Spacer(),
                      Text(
                        'Còn: ${product.stockQuantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.stockQuantity > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 20),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminProductFormScreen(
                        categoryId: widget.categoryId,
                        categoryName: widget.categoryName,
                        productId: product.id,
                      ),
                    ),
                  );
                  _loadProducts();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () => _deleteProduct(product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: AppColors.backgroundGrey,
      child: const Icon(Icons.image, color: AppColors.grey, size: 32),
    );
  }
}
