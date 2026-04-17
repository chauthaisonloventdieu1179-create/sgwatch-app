import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/price_formatter.dart';
import 'package:sgwatch_app/features/address/data/datasources/address_remote_datasource.dart';
import 'package:sgwatch_app/features/address/data/models/address_model.dart';
import 'package:sgwatch_app/features/address/presentation/address_list_screen.dart';
import 'package:sgwatch_app/features/address/presentation/address_viewmodel.dart';
import 'package:sgwatch_app/features/cart/data/models/cart_item_model.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/cart/presentation/checkout_success_screen.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_viewmodel.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cartVM = CartViewModel();
  final _addressVM = AddressViewModel(AddressRemoteDatasource(ApiClient()));
  final _profileVM = ProfileViewModel();
  final _noteController = TextEditingController();
  final _discountController = TextEditingController();

  AddressModel? _selectedAddress;
  bool _usePoint = false;
  String? _selectedPaymentMethod;
  bool _isPlacingOrder = false;

  // Discount code
  bool _isApplyingDiscount = false;
  String? _appliedDiscountCode;
  int _discountAmount = 0; // Fixed JPY amount

  @override
  void initState() {
    super.initState();
    _addressVM.addListener(_onChanged);
    _profileVM.addListener(_onChanged);
    _addressVM.loadAddresses();
    _profileVM.loadUserPoint();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {
        // Auto-select default address
        if (_selectedAddress == null && _addressVM.addresses.isNotEmpty) {
          final defaultAddr = _addressVM.addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => _addressVM.addresses.first,
          );
          _selectAddress(defaultAddr);
        }
      });
    }
  }

  Future<void> _selectAddress(AddressModel address) async {
    // Fetch full detail để có jp_detail.prefecture đầy đủ cho tính ship
    if (address.id != null) {
      final detail = await _addressVM.getAddressDetail(address.id!);
      if (detail != null && mounted) {
        setState(() {
          _selectedAddress = detail;
          _selectedPaymentMethod = null;
        });
        return;
      }
    }
    if (mounted) {
      setState(() {
        _selectedAddress = address;
        _selectedPaymentMethod = null;
      });
    }
  }

  @override
  void dispose() {
    _addressVM.removeListener(_onChanged);
    _profileVM.removeListener(_onChanged);
    _addressVM.dispose();
    _profileVM.dispose();
    _noteController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  bool get _isVietnam => _selectedAddress?.isVn ?? false;

  List<String> get _paymentMethods {
    if (_isVietnam) {
      return [
        'Chuyển khoản toàn bộ',
        'Cọc 1 triệu (Thanh toán khi nhận hàng)',
        'Stripe (Visa, Mastercard, AmEx, JCB, Discover)',
      ];
    }
    return [
      'Chuyển khoản toàn bộ',
      'Daibiki (代引き)',
      'Stripe (Visa, Mastercard, AmEx, JCB, Discover)',
    ];
  }

  /// Maps display label → API value for payment_method field.
  static const _paymentMethodApiMap = <String, String>{
    'Cọc 1 triệu (Thanh toán khi nhận hàng)': 'deposit_transfer',
    'Chuyển khoản toàn bộ': 'bank_transfer',
    'Daibiki (代引き)': 'cod',
    'Stripe (Visa, Mastercard, AmEx, JCB, Discover)': 'stripe',
  };

  String? get _paymentMethodApiValue => _selectedPaymentMethod != null
      ? _paymentMethodApiMap[_selectedPaymentMethod]
      : null;

  double get _subtotal => _cartVM.totalPrice;
  double get _shippingFee {
    if (_selectedAddress == null) return 0;
    // Vietnam → +1000 JPY ship
    if (_selectedAddress!.isVn) return 1000;
    // Japan Hokkaido / Okinawa → +1000 JPY ship
    if (_selectedAddress!.isJp) {
      final pref = _selectedAddress!.jpDetail?.prefecture ?? '';
      if (pref.contains('北海道') || pref.contains('沖縄')) return 1000;
    }
    return 0;
  }

  bool get _isDaibiki => _selectedPaymentMethod == 'Daibiki (代引き)';
  bool get _isStripe =>
      _selectedPaymentMethod != null &&
      _selectedPaymentMethod!.startsWith('Stripe');
  double get _daibikiFee => _isDaibiki ? 1500 : 0;
  double get _stripeFee {
    if (!_isStripe) return 0;
    if (_subtotal < 50000) return 1500;
    if (_subtotal < 100000) return 3000;
    return 5000;
  }

  double get _serviceFee => _daibikiFee + _stripeFee;
  double get _discount => _discountAmount > 0 ? _discountAmount.toDouble() : 0;
  double get _pointDiscount => _usePoint ? _profileVM.point.toDouble() : 0;
  double get _grandTotal =>
      (_subtotal + _shippingFee + _serviceFee - _discount - _pointDiscount)
          .clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 120,
              ),
              child: Column(
                children: [
                  _buildAddressSection(),
                  const SizedBox(height: 12),
                  _buildProductList(),
                  const SizedBox(height: 12),
                  _buildShippingSection(),
                  const SizedBox(height: 12),
                  _buildNoteSection(),
                  const SizedBox(height: 12),
                  _buildDiscountSection(),
                  const SizedBox(height: 12),
                  _buildPointSection(),
                  const SizedBox(height: 12),
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 8),
                  _buildShippingNote(),
                  const SizedBox(height: 12),
                  _buildOrderSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  // ─── App Bar ───────────────────────────────────────────────
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
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: AppColors.black,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Thanh toán',
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

  // ─── Shipping Note ─────────────────────────────────────────
  Widget _buildShippingNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.red.shade700,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(text: 'Miễn phí vận chuyển '),
                  TextSpan(
                    text: 'toàn bộ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' đơn hàng, ngoại trừ 3 vùng sau sẽ tính phí ship ',
                  ),
                  TextSpan(
                    text: '+1,000¥ (≈175,000đ)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ': Hokkaido, Okinawa (Nhật Bản) và Việt Nam.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Address Section ───────────────────────────────────────
  Widget _buildAddressSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ nhận hàng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showAddressPicker,
                child: const Text(
                  'Thay đổi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_addressVM.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_selectedAddress != null) ...[
            Text(
              _selectedAddress!.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            if (_selectedAddress!.phone != null &&
                _selectedAddress!.phone!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                _selectedAddress!.phone!,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              _selectedAddress!.fullAddress,
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ] else
            GestureDetector(
              onTap: _showAddressPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Chọn địa chỉ nhận hàng',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddressPicker() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressListScreen(
          selectionMode: true,
          selectedAddressId: _selectedAddress?.id,
        ),
      ),
    );
    if (result != null && mounted) {
      await _selectAddress(result);
    }
  }

  // ─── Discount Code Logic ───────────────────────────────────
  Future<void> _applyDiscountCode() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingDiscount = true);

    try {
      final response = await ApiClient().get(
        '${Endpoints.discountCodes}/$code',
      );
      if (!mounted) return;

      final discountCode =
          response.data['data']['discount_code'] as Map<String, dynamic>;
      final available = discountCode['available'] as bool;
      final amount = (discountCode['amount'] as num?)?.toInt() ?? 0;

      if (!available) {
        setState(() => _isApplyingDiscount = false);
        _showDiscountDialog(
          title: 'Mã giảm giá hết lượt',
          message: 'Mã giảm giá này đã hết số lượng sử dụng.',
          isError: true,
        );
      } else {
        setState(() {
          _isApplyingDiscount = false;
          _appliedDiscountCode = code;
          _discountAmount = amount;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isApplyingDiscount = false);
      _showDiscountDialog(
        title: 'Không tìm thấy',
        message: 'Mã giảm giá không tồn tại hoặc không hợp lệ.',
        isError: true,
      );
    }
  }

  void _clearDiscountCode() {
    setState(() {
      _appliedDiscountCode = null;
      _discountAmount = 0;
      _discountController.clear();
    });
  }

  void _showDiscountDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.primary : Colors.green,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Đóng',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product List ──────────────────────────────────────────
  Widget _buildProductList() {
    final items = _cartVM.items;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Sản phẩm (${_cartVM.totalQuantity})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(items.length, (index) {
            final item = items[index];
            return _buildProductItem(item, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(CartItemModel item, int number) {
    return Padding(
      padding: EdgeInsets.only(top: number > 1 ? 12 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number
          SizedBox(
            width: 20,
            child: Text(
              '#$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
          ),
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.greyLight),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.watch, size: 28, color: AppColors.greyLight),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      PriceFormatter.formatJPY(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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

  // ─── Shipping Section ──────────────────────────────────────
  Widget _buildShippingSection() {
    return _buildCard(
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vận chuyển',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Đảm bảo giao dịch an toàn và bảo mật',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Note Section ──────────────────────────────────────────
  Widget _buildNoteSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '(Thời gian nhận hàng mong muốn)',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: AppColors.black),
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú cho đơn hàng...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.greyPlaceholder,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Discount Code Section ─────────────────────────────────
  Widget _buildDiscountSection() {
    final isApplied = _appliedDiscountCode != null;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mã giảm giá',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  readOnly: isApplied,
                  style: const TextStyle(fontSize: 13, color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.greyPlaceholder,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: isApplied,
                    fillColor: isApplied
                        ? Colors.green.withValues(alpha: 0.06)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.greyLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isApplied ? Colors.green : AppColors.greyLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: isApplied
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '-${PriceFormatter.formatJPY(_discountAmount.toDouble())}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: isApplied
                    ? OutlinedButton(
                        onPressed: _clearDiscountCode,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.greyLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xóa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _isApplyingDiscount
                            ? null
                            : _applyDiscountCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isApplyingDiscount
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Áp dụng',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
              ),
            ],
          ),
          if (isApplied) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Đã áp dụng mã "$_appliedDiscountCode" — giảm ${PriceFormatter.formatJPY(_discountAmount.toDouble())}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Point Section ─────────────────────────────────────────
  Widget _buildPointSection() {
    final maxPoint = (_subtotal * 0.5).toInt();
    final availablePoint = _profileVM.point;
    final usablePoint = availablePoint > maxPoint ? maxPoint : availablePoint;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SGWATCH Point',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              Switch(
                value: _usePoint,
                onChanged: availablePoint > 0
                    ? (value) => setState(() => _usePoint = value)
                    : null,
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          Text(
            'Bạn có $availablePoint point${_usePoint ? ' (Sử dụng $usablePoint point)' : ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  // ─── Payment Method Section ────────────────────────────────
  Widget _buildPaymentMethodSection() {
    final methods = _paymentMethods;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAddress == null)
            const Text(
              'Vui lòng chọn địa chỉ trước',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            )
          else
            ...methods.map((method) {
              final isSelected = _selectedPaymentMethod == method;
              final isDaibikiMethod = method == 'Daibiki (代引き)';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPaymentMethod = method),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: methods.indexOf(method) > 0 ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.greyLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 20,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.greyPlaceholder,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  method,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? AppColors.black
                                        : AppColors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isDaibikiMethod) ...[
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Thanh toán khi nhận hàng',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (method.contains('Stripe'))
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCardIcon('Visa'),
                                const SizedBox(width: 4),
                                _buildCardIcon('MC'),
                                const SizedBox(width: 4),
                                _buildCardIcon('JCB'),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (isSelected && isDaibikiMethod) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Phí dịch vụ +1,500¥',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCardIcon(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.grey,
        ),
      ),
    );
  }

  // ─── Order Summary ─────────────────────────────────────────
  Widget _buildOrderSummary() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng tiền',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Thành tiền', PriceFormatter.formatJPY(_subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Vận chuyển',
            _shippingFee > 0
                ? '${PriceFormatter.formatJPY(_shippingFee)} (≈ ${PriceFormatter.formatVND(_shippingFee * 175)})'
                : 'Miễn phí',
          ),
          if (_serviceFee > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              _isDaibiki ? 'Phí dịch vụ Daibiki' : 'Phí dịch vụ Stripe',
              '+${PriceFormatter.formatJPY(_serviceFee)}',
              valueColor: AppColors.primary,
            ),
          ],
          if (_discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Giảm giá',
              '-${PriceFormatter.formatJPY(_discount)}',
              valueColor: Colors.green,
            ),
          ],
          if (_usePoint && _pointDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'SGWATCH Point',
              '-${PriceFormatter.formatJPY(_pointDiscount)}',
              valueColor: Colors.green,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.greyLight),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
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
                    PriceFormatter.formatJPY(_grandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '≈ ${PriceFormatter.formatVND(_grandTotal * 175)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (_selectedAddress?.isVn == true) ...[
            const SizedBox(height: 10),
            const Text(
              '🚚 Thời gian ship là 7 đến 10 ngày',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 15,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PriceFormatter.formatJPY(_grandTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '≈ ${PriceFormatter.formatVND(_grandTotal * 175)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: _canPlaceOrder() ? _placeOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.greyLight,
                  disabledForegroundColor: AppColors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Đặt hàng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canPlaceOrder() {
    if (_selectedAddress == null) return false;
    if (_selectedPaymentMethod == null) return false;
    if (_isPlacingOrder) return false;
    if (_cartVM.items.isEmpty) return false;
    return true;
  }

  Future<void> _placeOrder() async {
    final paymentMethod = _paymentMethodApiValue;
    if (_selectedAddress?.id == null || paymentMethod == null) return;

    setState(() => _isPlacingOrder = true);

    try {
      final body = <String, dynamic>{
        'address_id': _selectedAddress!.id,
        'payment_method': paymentMethod,
        'shipping_method': 'standard',
        'use_points': _usePoint ? 1 : 0,
      };
      if (_noteController.text.trim().isNotEmpty) {
        body['note'] = _noteController.text.trim();
      }
      if (_appliedDiscountCode != null) {
        body['discount_code'] = _appliedDiscountCode;
      }

      final response = await ApiClient().post(Endpoints.checkout, data: body);
      if (!mounted) return;

      final responseData = response.data['data'] as Map<String, dynamic>?;
      final order = responseData?['order'] as Map<String, dynamic>?;
      final orderId = order?['id'] as int?;
      final orderNumber = order?['order_number'] as String?;

      if (paymentMethod == 'stripe' && responseData != null) {
        // Keep _isPlacingOrder = true — prevents double-tap while Stripe sheet is open
        await _handleStripePayment(
          responseData,
          orderId: orderId,
          orderNumber: orderNumber,
        );
      } else {
        setState(() => _isPlacingOrder = false);
        _onOrderSuccess(orderJson: order);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);

      String errorMsg = 'Đặt hàng thất bại. Vui lòng thử lại.';
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        debugPrint('[Checkout] Error ${e.response!.statusCode}: $data');
        // Server trả message hoặc errors
        final msg = data['message']?.toString();
        final errors = data['errors'] as Map?;
        if (errors != null && errors.isNotEmpty) {
          errorMsg = errors.values
              .expand((v) => v is List ? v : [v])
              .join('\n');
        } else if (msg != null && msg.isNotEmpty) {
          errorMsg = msg;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.primary),
      );
    }
  }

  Future<void> _handleStripePayment(
    Map<String, dynamic> data, {
    int? orderId,
    String? orderNumber,
  }) async {
    final clientSecret = data['stripe_client_secret'] as String?;
    final publicKey = data['stripe_public_key'] as String?;

    if (clientSecret == null || publicKey == null) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không nhận được thông tin thanh toán Stripe.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    try {
      Stripe.publishableKey = publicKey;
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SGWatch',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Payment sheet closed with success
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      _onOrderSuccess(orderId: orderId, orderNumber: orderNumber);
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      if (e.error.code == FailureCode.Canceled) {
        // Order đã được tạo nhưng chưa thanh toán → xóa cart và cho phép retry
        _cartVM.clearCache();
        _showStripeRetrySheet(orderId: orderId, orderNumber: orderNumber);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán thất bại: ${e.error.localizedMessage ?? e.error.message}',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showStripeRetrySheet({int? orderId, String? orderNumber}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _StripeRetrySheet(
        orderId: orderId,
        orderNumber: orderNumber,
        onRetry: (newOrderId, newOrderNumber) =>
            _retryStripePayment(newOrderId, newOrderNumber),
        onClose: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }

  Future<void> _retryStripePayment(int? orderId, String? orderNumber) async {
    if (orderId == null) return;
    try {
      final endpoint = Endpoints.retryPayment.replaceFirst(
        '{id}',
        orderId.toString(),
      );
      final response = await ApiClient().post(endpoint);
      if (!mounted) return;

      final data = response.data['data'] as Map<String, dynamic>?;
      final clientSecret = data?['stripe_client_secret'] as String?;
      final publicKey = data?['stripe_public_key'] as String?;

      if (clientSecret == null || publicKey == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không nhận được thông tin thanh toán.'),
          ),
        );
        return;
      }

      Stripe.publishableKey = publicKey;
      await Stripe.instance.applySettings();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SGWatch',
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      _onOrderSuccess(orderId: orderId, orderNumber: orderNumber);
    } on StripeException catch (e) {
      if (!mounted) return;
      if (e.error.code == FailureCode.Canceled) {
        // Hủy thanh toán lần 2 → đóng tất cả và về home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán thất bại: ${e.error.localizedMessage ?? e.error.message}',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
      );
    }
  }

  void _onOrderSuccess({
    Map<String, dynamic>? orderJson,
    int? orderId,
    String? orderNumber,
  }) {
    // Clear cart after successful order
    _cartVM.clearCache();

    if (orderJson != null) {
      // Non-Stripe: navigate to success screen with payment info
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CheckoutSuccessScreen(orderJson: orderJson),
        ),
      );
    } else {
      // Stripe: just show snackbar and pop
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderNumber != null
                ? 'Đặt hàng thành công! Đơn hàng $orderNumber'
                : 'Đặt hàng thành công!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  // ─── Shared Card Container ─────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
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

// ── Stripe retry bottom sheet ─────────────────────────────────────────────────

class _StripeRetrySheet extends StatefulWidget {
  final int? orderId;
  final String? orderNumber;
  final Future<void> Function(int? orderId, String? orderNumber) onRetry;
  final VoidCallback onClose;

  const _StripeRetrySheet({
    required this.orderId,
    required this.orderNumber,
    required this.onRetry,
    required this.onClose,
  });

  @override
  State<_StripeRetrySheet> createState() => _StripeRetrySheetState();
}

class _StripeRetrySheetState extends State<_StripeRetrySheet> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment_outlined,
              size: 28,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thanh toán bị hủy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng ${widget.orderNumber ?? ''} đã được tạo nhưng chưa thanh toán.\nBạn có muốn thanh toán lại không?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isRetrying
                  ? null
                  : () async {
                      setState(() => _isRetrying = true);
                      final nav = Navigator.of(context);
                      await widget.onRetry(widget.orderId, widget.orderNumber);
                      if (mounted && nav.canPop()) nav.pop();
                    },
              icon: _isRetrying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.credit_card_outlined, size: 18),
              label: Text(
                _isRetrying ? 'Đang xử lý...' : 'Thanh toán lại',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _isRetrying ? null : widget.onClose,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.greyLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
