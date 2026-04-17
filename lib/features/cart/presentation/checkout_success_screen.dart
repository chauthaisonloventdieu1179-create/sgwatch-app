import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/orders/data/models/order_model.dart';

class CheckoutSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> orderJson;

  const CheckoutSuccessScreen({
    super.key,
    required this.orderJson,
  });

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen> {
  late final OrderDetailModel _order;
  XFile? _selectedImage;
  bool _isUploading = false;
  bool _uploaded = false;

  @override
  void initState() {
    super.initState();
    _order = OrderDetailModel.fromJson(widget.orderJson);
  }

  bool get _isDaibiki => _order.paymentMethod == 'cod';

  String get _transferContent =>
      '${_order.orderNumber} - ${_order.shippingName}';

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
        _order.id.toString(),
      );
      await ApiClient().post(endpoint, data: formData);

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploaded = true;
      });
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Pop all checkout screens back to home
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SelectionArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSuccessHeader(),
                      const SizedBox(height: 16),
                      _buildOrderSummary(),
                      if (!_isDaibiki) ...[
                        const SizedBox(height: 16),
                        _buildBankInfoCard(),
                        const SizedBox(height: 16),
                        _buildUploadSection(),
                      ],
                      const SizedBox(height: 24),
                      _buildBackButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
      child: const Row(
        children: [
          SizedBox(width: 30),
          Expanded(
            child: Text(
              'Đặt hàng thành công',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
    );
  }

  // ── Success header ──────────────────────────────────────────

  Widget _buildSuccessHeader() {
    return _card(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle,
                size: 40, color: Colors.green.shade600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Đặt hàng thành công!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _order.orderNumber,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (!_isDaibiki)
            Container(
              padding: const EdgeInsets.all(10),
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
                      'Vui lòng chuyển khoản và tải lên biên lai để xác nhận đơn hàng',
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
        ],
      ),
    );
  }

  // ── Order summary ───────────────────────────────────────────

  Widget _buildOrderSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...(_order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: AppColors.backgroundGrey,
                        child: Image.network(
                          item.productImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.watch,
                            size: 22,
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
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${PriceFormatter.formatJPY(item.unitPrice)} x${item.quantity}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
          const Divider(height: 1, color: AppColors.greyLight),
          const SizedBox(height: 10),
          if (_order.shippingFee > 0)
            _summaryRow(
                'Phí vận chuyển', PriceFormatter.formatJPY(_order.shippingFee)),
          if (_order.codFee > 0)
            _summaryRow(
                'Phí dịch vụ Daibiki', PriceFormatter.formatJPY(_order.codFee)),
          if (_order.stripeFee > 0)
            _summaryRow(
                'Phí dịch vụ Stripe', PriceFormatter.formatJPY(_order.stripeFee)),
          if (_order.discountAmount > 0)
            _summaryRow(
                'Giảm giá', '-${PriceFormatter.formatJPY(_order.discountAmount)}',
                color: const Color(0xFF4CAF50)),
          if (_order.paymentMethod == 'deposit_transfer' && _order.depositAmount > 0)
            _summaryRow(
              'Tiền cọc cần thanh toán',
              PriceFormatter.formatVND(_order.depositAmount),
              color: AppColors.primary,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceFormatter.formatJPY(_order.totalAmount),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '≈ ${PriceFormatter.formatVND(_order.totalAmount * 175)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.black)),
        ],
      ),
    );
  }

  // ── Bank info card (VN vs JP) ────────────────────────────────

  Widget _buildBankInfoCard() {
    return Column(
      children: [
        // ── Khối 1: Chuyển khoản Việt Nam ──
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance, size: 18, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text(
                    'Chuyển khoản Việt Nam',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _bankRow('Ngân hàng', 'VIETCOMBANK'),
              _bankRow('Số tài khoản', '9042628888'),
              _bankRow('Chủ tài khoản', 'TRAN TOAN'),
              _bankRow(
                _order.paymentMethod == 'deposit_transfer' ? 'Tiền cọc' : 'Số tiền',
                _order.paymentMethod == 'deposit_transfer' && _order.depositAmount > 0
                    ? PriceFormatter.formatVND(_order.depositAmount)
                    : PriceFormatter.formatVND(_order.totalAmount * 175),
                highlight: true,
              ),
              _bankRow('Nội dung CK', _transferContent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankRow(String label, String value, {bool highlight = false}) {
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

  // ── Upload section ──────────────────────────────────────────

  Widget _buildUploadSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (_uploaded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Đã tải biên lai thành công!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
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
                                  _uploadPlaceholder(hasFile: true),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _uploadPlaceholder(hasFile: false),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
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
          ],
        ],
      ),
    );
  }

  Widget _uploadPlaceholder({required bool hasFile}) {
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
          hasFile ? 'Đã chọn ảnh — nhấn để đổi' : 'Nhấn để chọn ảnh biên lai',
          style: TextStyle(
            fontSize: 13,
            color: hasFile ? Colors.green : AppColors.greyPlaceholder,
          ),
        ),
      ],
    );
  }

  // ── Back button ─────────────────────────────────────────────

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.greyLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Về trang chủ',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Card helper ─────────────────────────────────────────────

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
}
