import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_order_model.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_order_detail_screen.dart';

class AdminProcessingOrdersScreen extends StatefulWidget {
  const AdminProcessingOrdersScreen({super.key});

  @override
  State<AdminProcessingOrdersScreen> createState() =>
      _AdminProcessingOrdersScreenState();
}

class _AdminProcessingOrdersScreenState
    extends State<AdminProcessingOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _ds = AdminDatasource(ApiClient());

  // Tab 0: processing, Tab 1: confirmed
  final List<List<AdminOrderModel>> _orders = [[], []];
  final List<bool> _isLoading = [false, false];
  final List<int> _currentPage = [1, 1];
  final List<bool> _hasMore = [true, true];
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  static const _statuses = ['processing', 'confirmed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollControllers[0].addListener(() => _onScroll(0));
    _scrollControllers[1].addListener(() => _onScroll(1));
    _loadOrders(0);
    _loadOrders(1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onScroll(int tab) {
    final ctrl = _scrollControllers[tab];
    if (ctrl.position.pixels >= ctrl.position.maxScrollExtent - 150) {
      _loadMoreOrders(tab);
    }
  }

  Future<void> _loadOrders(int tab) async {
    if (_isLoading[tab]) return;
    setState(() {
      _isLoading[tab] = true;
      _orders[tab].clear();
      _currentPage[tab] = 1;
      _hasMore[tab] = true;
    });
    try {
      final res = await _ds.getOrders(
          page: 1, status: _statuses[tab]);
      setState(() {
        _orders[tab] = res.orders;
        _hasMore[tab] = res.currentPage < res.lastPage;
        _currentPage[tab] = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading[tab] = false);
    }
  }

  Future<void> _loadMoreOrders(int tab) async {
    if (_isLoading[tab] || !_hasMore[tab]) return;
    final nextPage = _currentPage[tab] + 1;
    setState(() => _isLoading[tab] = true);
    try {
      final res = await _ds.getOrders(
          page: nextPage, status: _statuses[tab]);
      setState(() {
        _orders[tab].addAll(res.orders);
        _hasMore[tab] = res.currentPage < res.lastPage;
        _currentPage[tab] = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading[tab] = false);
    }
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
          'Đơn đang xử lý',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đã xác nhận'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [0, 1].map((tab) => _buildOrderList(tab)).toList(),
      ),
    );
  }

  Widget _buildOrderList(int tab) {
    if (_isLoading[tab] && _orders[tab].isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_orders[tab].isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Không có đơn hàng',
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadOrders(tab),
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
      onRefresh: () => _loadOrders(tab),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollControllers[tab],
        padding: const EdgeInsets.all(16),
        itemCount: _orders[tab].length + (_hasMore[tab] ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _orders[tab].length) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.primary),
            ));
          }
          return _buildOrderCard(_orders[tab][index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(AdminOrderModel order) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AdminOrderDetailScreen(orderId: order.id)),
        );
        _loadOrders(0);
        _loadOrders(1);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.user?.fullName ?? order.shippingName,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(order.createdAt),
              style: const TextStyle(fontSize: 11, color: AppColors.grey),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} sản phẩm',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                Text(
                  PriceFormatter.formatJPY(order.totalAmount.toDouble()),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    switch (status) {
      case 'processing':
        bg = Colors.orange;
        break;
      case 'confirmed':
        bg = Colors.blue;
        break;
      default:
        bg = AppColors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg),
      ),
      child: Text(
        AdminOrderModel(
          id: 0,
          orderNumber: '',
          orderType: '',
          status: status,
          paymentStatus: '',
          paymentMethod: '',
          shippingMethod: '',
          subtotal: 0,
          shippingFee: 0,
          codFee: 0,
          stripeFee: 0,
          totalAmount: 0,
          currency: '',
          shippingName: '',
          shippingPhone: '',
          shippingAddress: '',
          shippingCountry: '',
          createdAt: DateTime.now(),
          items: const [],
        ).statusLabel,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: bg),
      ),
    );
  }
}
