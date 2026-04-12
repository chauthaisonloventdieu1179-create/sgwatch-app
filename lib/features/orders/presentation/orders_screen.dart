import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/orders/data/models/order_model.dart';
import 'package:sgwatch_app/features/orders/presentation/order_detail_screen.dart';
import 'package:sgwatch_app/features/orders/presentation/order_viewmodel.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrderViewModel _viewModel;

  static const List<_OrderTab> _tabs = [
    _OrderTab(icon: Icons.access_time, label: 'Chờ xác\nnhận'),
    _OrderTab(icon: Icons.local_shipping_outlined, label: 'Chờ giao\nhàng'),
    _OrderTab(icon: Icons.check_box_outlined, label: 'Đã hoàn\nthành'),
    _OrderTab(icon: Icons.close, label: 'Đã hủy'),
    _OrderTab(icon: Icons.currency_exchange, label: 'Hoàn tiền'),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = OrderViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadInitialTab();
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
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
            ),
          ),
          const Expanded(
            child: Text(
              'Đơn hàng',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final tab = _tabs[index];
        final isSelected = _viewModel.selectedTab == index;

        return Expanded(
          child: GestureDetector(
            onTap: () => _viewModel.selectTab(index),
            child: Container(
              height: 80,
              margin: EdgeInsets.only(right: index < _tabs.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.black : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.greyPlaceholder),
                boxShadow: isSelected
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab.icon,
                    size: 26,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.white : AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContent() {
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _viewModel.refreshCurrentTab(),
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

    final orders = _viewModel.currentOrders;

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _viewModel.refreshCurrentTab(),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  bool _needsPayment(OrderListItem order) =>
      order.status == OrderStatus.pending &&
      order.paymentStatus == 'pending' &&
      order.paymentMethod != 'stripe';

  void _navigateToDetail(OrderListItem order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId: order.id,
          orderNumber: order.orderNumber,
          viewModel: _viewModel,
        ),
      ),
    ).then((cancelled) {
      if (cancelled == true) {
        _viewModel.refreshCurrentTab();
      }
    });
  }

  Widget _buildOrderCard(OrderListItem order) {
    final showPayHint = _needsPayment(order);

    return GestureDetector(
      onTap: () => _navigateToDetail(order),
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
        child: Column(
          children: [
            // Header: order number + status badge
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: order.status.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDateTime(order.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            // Payment reminder
            if (showPayHint)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Vui lòng thanh toán để xác nhận đơn hàng',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1, color: AppColors.greyLight),
            // Footer: item count + total + optional pay button
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.totalItems} sản phẩm',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      if (showPayHint) ...[
                        GestureDetector(
                          onTap: () => _navigateToDetail(order),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Thanh toán',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Tổng: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            PriceFormatter.formatJPY(order.totalAmount),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '≈ ${PriceFormatter.formatVND(order.totalAmount * 175)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.luggage,
            size: 70,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn không có đơn hàng nào\nthuộc trạng thái này.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OrderTab {
  final IconData icon;
  final String label;

  const _OrderTab({required this.icon, required this.label});
}
