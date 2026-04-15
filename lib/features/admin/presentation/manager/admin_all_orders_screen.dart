import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_order_model.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_order_detail_screen.dart';

class AdminAllOrdersScreen extends StatefulWidget {
  const AdminAllOrdersScreen({super.key});

  @override
  State<AdminAllOrdersScreen> createState() => _AdminAllOrdersScreenState();
}

class _AdminAllOrdersScreenState extends State<AdminAllOrdersScreen> {
  final _ds = AdminDatasource(ApiClient());
  final _scrollController = ScrollController();

  List<AdminOrderModel> _orders = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedStatus;

  static const _statusOptions = [
    (null, 'Tất cả'),
    ('pending', 'Chờ xử lý'),
    ('waiting_order', 'Chờ đặt hàng'),
    ('processing', 'Đang xử lý'),
    ('confirmed', 'Đã xác nhận'),
    ('shipping', 'Đang giao'),
    ('delivered', 'Đã giao'),
    ('completed', 'Hoàn thành'),
    ('cancelled', 'Đã hủy'),
    ('refunded', 'Hoàn tiền'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      _loadMore();
    }
  }

  Future<void> _loadOrders() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _orders = [];
      _currentPage = 1;
      _hasMore = true;
    });
    try {
      final res = await _ds.getOrders(page: 1, status: _selectedStatus);
      setState(() {
        _orders = res.orders;
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
      final res =
          await _ds.getOrders(page: nextPage, status: _selectedStatus);
      setState(() {
        _orders.addAll(res.orders);
        _hasMore = res.currentPage < res.lastPage;
        _currentPage = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
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
          'Tất cả đơn hàng',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.white),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedStatus != null) _buildFilterChip(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    final label = _statusOptions
        .firstWhere((s) => s.$1 == _selectedStatus,
            orElse: () => (null, 'Tất cả'))
        .$2;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Chip(
            label: Text(label, style: const TextStyle(fontSize: 12)),
            backgroundColor:
                AppColors.primary.withValues(alpha: 0.1),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              _selectedStatus = null;
              _loadOrders();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _orders.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Không có đơn hàng',
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadOrders,
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
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          if (index == _orders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return _buildOrderCard(_orders[index]);
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
              builder: (_) =>
                  AdminOrderDetailScreen(orderId: order.id)),
        );
        _loadOrders();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
                _buildStatusBadge(order.status, order.statusLabel),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.user?.fullName ?? order.shippingName,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(order.createdAt),
              style:
                  const TextStyle(fontSize: 11, color: AppColors.grey),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} sản phẩm',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey),
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

  Widget _buildStatusBadge(String status, String label) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'processing':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'delivered':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'refunded':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Lọc theo trạng thái',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._statusOptions.map((s) => ListTile(
                title: Text(s.$2),
                trailing: _selectedStatus == s.$1
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedStatus = s.$1);
                  _loadOrders();
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
