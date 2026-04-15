import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_order_model.dart';
import 'package:sgwatch_app/features/admin/presentation/chat/admin_chat_room_screen.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _ds = AdminDatasource(ApiClient());
  AdminOrderModel? _order;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await _ds.getOrderDetail(widget.orderId);
      setState(() => _order = order);
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _ds.updateOrderStatus(widget.orderId, newStatus);
      await _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi cập nhật trạng thái')),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updatePaymentStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _ds.updateOrderPaymentStatus(widget.orderId, newStatus);
      await _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thanh toán thành công')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi cập nhật thanh toán')),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showStatusDialog() {
    const statuses = [
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
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
            const Text('Chọn trạng thái đơn hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.55,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: statuses.map((s) => ListTile(
                        title: Text(s.$2),
                        trailing: _order?.status == s.$1
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (_order?.status != s.$1) _updateStatus(s.$1);
                        },
                      )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog() {
    const statuses = [
      ('pending', 'Chưa thanh toán'),
      ('paid', 'Đã thanh toán'),
    ];

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
          const Text('Trạng thái thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...statuses.map((s) => ListTile(
                title: Text(s.$2),
                trailing: _order?.paymentStatus == s.$1
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (_order?.paymentStatus != s.$1) {
                    _updatePaymentStatus(s.$1);
                  }
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
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
          _order?.orderNumber ?? 'Chi tiết đơn hàng',
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _order == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Không tải được đơn hàng',
                          style: TextStyle(color: AppColors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadOrder,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 12),
                        _buildCustomerCard(),
                        const SizedBox(height: 12),
                        _buildItemsCard(),
                        const SizedBox(height: 12),
                        _buildPriceCard(),
                        if (_order!.note != null &&
                            _order!.note!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildNoteCard(),
                        ],
                      ],
                    ),
                    if (_isUpdating)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                    _buildBottomActions(),
                  ],
                ),
    );
  }

  Widget _buildStatusCard() {
    final o = _order!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(o.orderNumber,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              _buildBadge(o.status, o.statusLabel, _statusColor(o.status)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormatter.formatDateTime(o.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const Divider(height: 20),
          _buildInfoRow('Thanh toán',
              _paymentMethodLabel(o.paymentMethod), AppColors.black),
          const SizedBox(height: 6),
          _buildInfoRow(
            'Trạng thái TT',
            o.paymentStatus == 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán',
            o.paymentStatus == 'paid' ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    final o = _order!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin khách hàng',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          if (o.user != null) ...[
            _buildInfoRow('Email', o.user!.email, AppColors.black),
            const SizedBox(height: 6),
          ],
          _buildInfoRow(
              'Người nhận', o.shippingName, AppColors.black),
          if (o.shippingPhone.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Điện thoại', o.shippingPhone, AppColors.black),
          ],
          const SizedBox(height: 6),
          _buildInfoRow('Địa chỉ', o.shippingAddress, AppColors.black),
          if (o.shippingCity != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Tỉnh/TP', o.shippingCity!, AppColors.black),
          ],
          const SizedBox(height: 6),
          _buildInfoRow('Quốc gia', o.shippingCountry, AppColors.black),
          if (o.shippingPostalCode != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
                'Mã bưu chính', o.shippingPostalCode!, AppColors.black),
          ],
          if (o.trackingNumber != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
                'Mã vận chuyển', o.trackingNumber!, AppColors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    final o = _order!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sản phẩm (${o.items.length})',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          ...o.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(AdminOrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (item.productSku != null) ...[
                  const SizedBox(height: 2),
                  Text('SKU: ${item.productSku}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey)),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('x${item.quantity}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey)),
                    Text(
                      PriceFormatter.formatJPY(item.unitPrice.toDouble()),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.backgroundGrey,
      child: const Icon(Icons.image, color: AppColors.grey),
    );
  }

  Widget _buildPriceCard() {
    final o = _order!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thanh toán',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          _buildPriceRow(
              'Tạm tính', PriceFormatter.formatJPY(o.subtotal.toDouble())),
          if (o.shippingFee > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow('Phí vận chuyển',
                PriceFormatter.formatJPY(o.shippingFee.toDouble())),
          ],
          if (o.codFee > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow(
                'Phí COD', PriceFormatter.formatJPY(o.codFee.toDouble())),
          ],
          if (o.stripeFee > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow('Phí Stripe',
                PriceFormatter.formatJPY(o.stripeFee.toDouble())),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
              Text(
                PriceFormatter.formatJPY(o.totalAmount.toDouble()),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ghi chú',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 8),
          Text(_order!.note!,
              style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final o = _order!;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: AppColors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Chat button
            if (o.user != null)
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminChatRoomScreen(
                          receiverId: o.user!.id,
                          userName: o.user!.fullName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (o.user != null) const SizedBox(width: 8),
            // Update status
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Trạng thái',
                    style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: _showStatusDialog,
              ),
            ),
            const SizedBox(width: 8),
            // Update payment
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('Thanh toán',
                    style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      o.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: _showPaymentDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: valueColor,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, color: AppColors.black)),
      ],
    );
  }

  Widget _buildBadge(String status, String label, Color color) {
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

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'stripe':
        return 'Stripe';
      case 'cod':
        return 'COD';
      case 'bank_transfer':
        return 'Chuyển khoản';
      default:
        return method;
    }
  }
}
