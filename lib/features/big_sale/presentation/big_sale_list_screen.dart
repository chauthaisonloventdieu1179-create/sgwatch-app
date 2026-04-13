import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/big_sale/data/models/big_sale_model.dart';
import 'package:sgwatch_app/features/big_sale/presentation/big_sale_screen.dart';
import 'package:sgwatch_app/features/big_sale/presentation/big_sale_viewmodel.dart';

class BigSaleListScreen extends StatefulWidget {
  const BigSaleListScreen({super.key});

  @override
  State<BigSaleListScreen> createState() => _BigSaleListScreenState();
}

class _BigSaleListScreenState extends State<BigSaleListScreen> {
  final _viewModel = BigSaleViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _viewModel.loadBigSales();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
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
        title: const Text(
          'BIG SALE',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
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
              onPressed: _viewModel.loadBigSales,
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

    if (_viewModel.bigSales.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có chương trình khuyến mãi.',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _viewModel.bigSales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _BigSaleCard(
          sale: _viewModel.bigSales[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    BigSaleScreen(id: _viewModel.bigSales[index].id),
              ),
            );
          },
        );
      },
    );
  }
}

class _BigSaleCard extends StatelessWidget {
  final BigSaleModel sale;
  final VoidCallback onTap;

  const _BigSaleCard({required this.sale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            if (sale.mediaUrl != null && sale.mediaUrl!.isNotEmpty)
              _buildBanner()
            else
              _buildBannerPlaceholder(),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sale.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (sale.salePercentage != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${sale.salePercentage}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (sale.description != null &&
                      sale.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      sale.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (sale.saleStartDate != null &&
                      sale.saleEndDate != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Từ ${sale.saleStartDate} đến ${sale.saleEndDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final thumbUrl = sale.thumbnailUrl?.isNotEmpty == true
        ? sale.thumbnailUrl!
        : (sale.mediaType != 'video' ? sale.mediaUrl : null);

    if (sale.mediaType == 'video') {
      return Stack(
        alignment: Alignment.center,
        children: [
          if (thumbUrl != null)
            Image.network(
              thumbUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 180,
                color: Colors.black87,
              ),
            )
          else
            Container(width: double.infinity, height: 180, color: Colors.black87),
          Container(
            width: double.infinity,
            height: 180,
            color: Colors.black38,
          ),
          const Icon(Icons.play_circle_outline, size: 56, color: AppColors.white),
        ],
      );
    }

    return Image.network(
      thumbUrl ?? sale.mediaUrl!,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildBannerPlaceholder(),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.local_offer, size: 48, color: AppColors.primary),
      ),
    );
  }
}
