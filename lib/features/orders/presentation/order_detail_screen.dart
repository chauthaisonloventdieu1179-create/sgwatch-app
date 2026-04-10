import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/app/config/env.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/orders/data/models/order_model.dart';
import 'package:sgwatch_app/features/orders/presentation/order_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final OrderViewModel viewModel;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.viewModel,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderDetailModel? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await widget.viewModel.loadOrderDetail(widget.orderId);
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _isLoading = false;
        _error = 'Không thể tải chi tiết đơn hàng.';
      });
    } else {
      setState(() {
        _isLoading = false;
        _detail = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(child: _buildBody()),
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
          Expanded(
            child: Text(
              widget.orderNumber,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
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

    final d = _detail!;
    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(d),
            const SizedBox(height: 12),
            _buildItemsCard(d),
            const SizedBox(height: 12),
            _buildPriceCard(d),
            const SizedBox(height: 12),
            _buildShippingCard(d),
            const SizedBox(height: 12),
            _buildPaymentCard(d),
            if (d.cancelReason != null) ...[
              const SizedBox(height: 12),
              _buildCancelCard(d),
            ],
            if (d.status == OrderStatus.completed) ...[
              const SizedBox(height: 16),
              _buildInvoiceButton(d),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Status card ─────────────────────────────────────────────

  Widget _buildStatusCard(OrderDetailModel d) {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trạng thái',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: d.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  d.status.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: d.status.color,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Ngày đặt',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatDateTime(d.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Items card ───────────────────────────────────────────────

  Widget _buildItemsCard(OrderDetailModel d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...d.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderDetailItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.backgroundGrey,
              child: Image.network(
                item.productImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.watch,
                  size: 28,
                  color: AppColors.greyLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    height: 1.3,
                  ),
                ),
                if (item.productSku.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'SKU: ${item.productSku}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      PriceFormatter.formatJPY(item.unitPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
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

  // ── Price breakdown card ─────────────────────────────────────

  Widget _buildPriceCard(OrderDetailModel d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _priceRow('Tạm tính', d.subtotal),
          if (d.shippingFee > 0) _priceRow('Phí vận chuyển', d.shippingFee),
          if (d.codFee > 0) _priceRow('Phí COD', d.codFee),
          if (d.discountAmount > 0)
            _priceRow('Giảm giá', -d.discountAmount, highlight: true),
          if (d.depositAmount > 0) _priceRow('Đặt cọc', d.depositAmount),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.greyLight),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                PriceFormatter.formatJPY(d.totalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (d.pointsEarned > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.stars, size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 4),
                Text(
                  '+${d.pointsEarned} điểm tích lũy',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool highlight = false}) {
    final isNegative = amount < 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          Text(
            isNegative
                ? '-${PriceFormatter.formatJPY(-amount)}'
                : PriceFormatter.formatJPY(amount),
            style: TextStyle(
              fontSize: 13,
              color: highlight ? const Color(0xFF4CAF50) : AppColors.black,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shipping card ────────────────────────────────────────────

  Widget _buildShippingCard(OrderDetailModel d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin giao hàng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.person_outline, d.shippingName),
          const SizedBox(height: 8),
          _infoRow(Icons.phone_outlined, d.shippingPhone),
          const SizedBox(height: 8),
          _infoRow(
            Icons.location_on_outlined,
            '${d.shippingAddress}, ${d.shippingCity}',
          ),
          if (d.trackingNumber != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.local_shipping_outlined,
                'Mã vận đơn: ${d.trackingNumber}'),
          ],
          if (d.shippingCarrier != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.business_outlined, 'Đơn vị vận chuyển: ${d.shippingCarrier}'),
          ],
          if (d.note != null && d.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.note_outlined, 'Ghi chú: ${d.note}'),
          ],
        ],
      ),
    );
  }

  // ── Payment card ─────────────────────────────────────────────

  Widget _buildPaymentCard(OrderDetailModel d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thanh toán',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.payment_outlined,
            _paymentMethodLabel(d.paymentMethod),
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.info_outline,
            _paymentStatusLabel(d.paymentStatus),
          ),
          // ── Payment receipt image ──
          if (d.status == OrderStatus.pending) ...[
            const SizedBox(height: 12),
            const Text(
              'Biên lai thanh toán',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (d.paymentReceipt != null) ...[
              // Show existing receipt image
              GestureDetector(
                onTap: () => _showFullImage(context, d.paymentReceipt!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    d.paymentReceipt!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40, color: AppColors.greyLight),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Đã upload biên lai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPaymentSheet(d),
                    child: const Text(
                      'Cập nhật ảnh',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // No receipt uploaded yet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chưa upload biên lai thanh toán',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentSheet(d),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text(
                    'Upload biên lai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Payment sheet ────────────────────────────────────────────

  // ── Invoice button ─────────────────────────────────────────

  Widget _buildInvoiceButton(OrderDetailModel d) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isDownloadingInvoice ? null : () => _downloadInvoice(d),
        icon: _isDownloadingInvoice
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white),
              )
            : const Icon(Icons.receipt_long_outlined, size: 20),
        label: Text(
          _isDownloadingInvoice ? 'Đang tải...' : 'In hóa đơn',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: AppColors.white,
          disabledBackgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  bool _isDownloadingInvoice = false;

  Future<void> _downloadInvoice(OrderDetailModel d) async {
    setState(() => _isDownloadingInvoice = true);

    try {
      final token = await LocalStorage.getToken();
      final endpoint = Endpoints.orderInvoice.replaceFirst('{id}', d.id.toString());
      final base = Env.baseURL.endsWith('/') ? Env.baseURL.substring(0, Env.baseURL.length - 1) : Env.baseURL;
      final url = '$base${Env.apiPath}$endpoint';

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/invoice_${d.orderNumber}.pdf';

      await Dio().download(
        url,
        filePath,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
        ),
      );

      if (!mounted) return;
      setState(() => _isDownloadingInvoice = false);

      await OpenFilex.open(filePath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloadingInvoice = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải hóa đơn: ${e.toString()}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  // ── Payment sheet ────────────────────────────────────────────

  void _showPaymentSheet(OrderDetailModel d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentReceiptSheet(
        order: d,
        onUploaded: () {
          _load(); // Reload detail
          widget.viewModel.refreshCurrentTab(); // Refresh list
        },
      ),
    );
  }

  // ── Cancel reason card ───────────────────────────────────────

  Widget _buildCancelCard(OrderDetailModel d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lý do hủy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            d.cancelReason ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          if (d.cancelledAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Hủy lúc: ${DateFormatter.formatDateTime(d.cancelledAt!)}',
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.black),
          ),
        ),
      ],
    );
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'stripe':
        return 'Thẻ tín dụng / Stripe';
      case 'cod':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      default:
        return method;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chưa thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'failed':
        return 'Thanh toán thất bại';
      default:
        return status;
    }
  }
}

// ─── Payment Receipt Bottom Sheet ──────────────────────────
class _PaymentReceiptSheet extends StatefulWidget {
  final OrderDetailModel order;
  final VoidCallback onUploaded;

  const _PaymentReceiptSheet({
    required this.order,
    required this.onUploaded,
  });

  @override
  State<_PaymentReceiptSheet> createState() => _PaymentReceiptSheetState();
}

class _PaymentReceiptSheetState extends State<_PaymentReceiptSheet> {
  XFile? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _selectedImage = file);
  }

  Future<void> _upload() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final formData = FormData.fromMap({
        'payment_receipt': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.name,
        ),
      });

      final endpoint = Endpoints.paymentReceipt.replaceFirst(
        '{id}',
        widget.order.id.toString(),
      );
      await ApiClient().post(endpoint, data: formData);

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onUploaded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tải biên lai thành công! Đang chờ xác nhận.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tải biên lai thất bại: ${e.toString()}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _openYouTubeGuide() async {
    final uri = Uri.parse('https://youtu.be/HmFedZcUJbQ');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar + close button
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: AppColors.grey),
                ),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Xác nhận chuyển khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                Text(
                  widget.order.orderNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankInfoCard(),
                  const SizedBox(height: 20),
                  // Upload area
                  const Text(
                    'Tải lên biên lai chuyển khoản',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chụp ảnh hoặc tải ảnh màn hình sau khi chuyển khoản',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedImage != null
                              ? Colors.green
                              : AppColors.greyLight,
                        ),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildUploadPlaceholder(hasFile: true),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _buildUploadPlaceholder(hasFile: false),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (_selectedImage == null || _isUploading) ? null : _upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.greyLight,
                  disabledForegroundColor: AppColors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Xác nhận đã chuyển khoản',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bank info card (VN vs JP) ────────────────────────────────

  Widget _buildBankInfoCard() {
    final isVN = widget.order.isVietnamAddress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB3D4F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, size: 18, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'Thông tin chuyển khoản',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isVN) ...[
            _buildBankRow('Ngân hàng', 'VIETCOMBANK'),
            _buildBankRow('Số tài khoản', '9042628888'),
            _buildBankRow('Chủ tài khoản', 'TRAN TOAN'),
            _buildBankRow(
              'Số tiền',
              PriceFormatter.formatJPY(widget.order.totalAmount),
              highlight: true,
            ),
            _buildBankRow('Nội dung CK', widget.order.orderNumber),
          ] else ...[
            const Text(
              'Quý khách vui lòng chuyển khoản qua hình thức sau và chụp lại bill xác nhận:',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildBankRow('Ngân hàng', 'みずほ銀行 (Mizuho)'),
            _buildBankRow('Chi nhánh', '天満橋支店 (Temmabashi)'),
            _buildBankRow('Loại TK', '普通 (Futsu)'),
            _buildBankRow('Số tài khoản', '3061217'),
            _buildBankRow('Chủ tài khoản', 'エスジージー(ド)\nSGG合同会社'),
            _buildBankRow(
              'Số tiền',
              PriceFormatter.formatJPY(widget.order.totalAmount),
              highlight: true,
            ),
            _buildBankRow('Nội dung CK', widget.order.orderNumber),
            const SizedBox(height: 8),
            // Tips box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCC02)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cách tìm tên chi nhánh:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gõ chữ テ sau đó tìm đến chi nhánh 天満橋支店',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE65100),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _openYouTubeGuide,
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_fill,
                            size: 20, color: Colors.red.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Video hướng dẫn chuyển khoản từ Yucho sang Mizuho',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? AppColors.primary : AppColors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã copy: $value'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.copy_rounded, size: 16, color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder({required bool hasFile}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasFile ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
          size: 36,
          color: hasFile ? Colors.green : AppColors.greyPlaceholder,
        ),
        const SizedBox(height: 8),
        Text(
          hasFile ? 'Đã chọn ảnh — nhấn để đổi' : 'Nhấn để chọn ảnh',
          style: TextStyle(
            fontSize: 13,
            color: hasFile ? Colors.green : AppColors.greyPlaceholder,
          ),
        ),
      ],
    );
  }
}
