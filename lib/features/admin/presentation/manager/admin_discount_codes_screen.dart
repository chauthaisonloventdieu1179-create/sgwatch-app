import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_discount_code_model.dart';

class AdminDiscountCodesScreen extends StatefulWidget {
  const AdminDiscountCodesScreen({super.key});

  @override
  State<AdminDiscountCodesScreen> createState() =>
      _AdminDiscountCodesScreenState();
}

class _AdminDiscountCodesScreenState extends State<AdminDiscountCodesScreen> {
  final _ds = AdminDatasource(ApiClient());
  List<DiscountCodeModel> _codes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _ds.getDiscountCodes();
      if (mounted) setState(() => _codes = list);
    } catch (e) {
      if (mounted) _showError('Tải dữ liệu thất bại');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(DiscountCodeModel code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Xoá mã giảm giá "${code.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Xoá', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _ds.deleteDiscountCode(code.id);
      _load();
    } catch (_) {
      if (mounted) _showError('Xoá thất bại');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _openForm({DiscountCodeModel? code}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _DiscountCodeFormScreen(ds: _ds, code: code),
      ),
    );
    if (result == true) {
      _load();
      _showSuccess(code == null ? 'Tạo mã thành công' : 'Cập nhật thành công');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Mã giảm giá',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _codes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.discount_outlined,
                          size: 48, color: AppColors.grey),
                      const SizedBox(height: 12),
                      const Text('Chưa có mã giảm giá',
                          style: TextStyle(color: AppColors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white),
                        child: const Text('Tải lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _codes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildCard(_codes[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(DiscountCodeModel code) {
    final expiry = _formatDate(code.expiresAt);
    final isExpired = _isExpired(code.expiresAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code.code,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(code.isActive, isExpired),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.grey),
                  onPressed: () => _openForm(code: code),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  onPressed: () => _delete(code),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfo(Icons.discount_outlined, 'Giảm',
                    '¥${_formatAmount(code.amount)}'),
                const SizedBox(width: 24),
                _buildInfo(Icons.confirmation_number_outlined, 'Số lượng',
                    '${code.quantity} lượt'),
                const SizedBox(width: 24),
                _buildInfo(Icons.calendar_today_outlined, 'Hết hạn', expiry,
                    valueColor: isExpired ? Colors.red : null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isExpired) {
    final label = isExpired ? 'Hết hạn' : (isActive ? 'Đang hoạt động' : 'Tắt');
    final color = isExpired
        ? Colors.red
        : (isActive ? Colors.green : AppColors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInfo(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.grey),
            const SizedBox(width: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.grey)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.black)),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatAmount(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  bool _isExpired(String? dateStr) {
    if (dateStr == null) return false;
    try {
      return DateTime.parse(dateStr).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}

// ── Form Screen ──────────────────────────────────────────────────────────────

class _DiscountCodeFormScreen extends StatefulWidget {
  final AdminDatasource ds;
  final DiscountCodeModel? code;

  const _DiscountCodeFormScreen({required this.ds, this.code});

  @override
  State<_DiscountCodeFormScreen> createState() =>
      _DiscountCodeFormScreenState();
}

class _DiscountCodeFormScreenState extends State<_DiscountCodeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _amountCtrl;
  DateTime? _expiresAt;
  bool _isLoading = false;

  bool get _isEdit => widget.code != null;

  @override
  void initState() {
    super.initState();
    final c = widget.code;
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _quantityCtrl = TextEditingController(text: c?.quantity.toString() ?? '');
    _amountCtrl = TextEditingController(text: c?.amount.toString() ?? '');
    if (c?.expiresAt != null) {
      try {
        _expiresAt = DateTime.parse(c!.expiresAt!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _quantityCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiresAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày hết hạn')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final d = _expiresAt!;
      final expiresAtStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} 00:00:00';
      if (_isEdit) {
        await widget.ds.updateDiscountCode(
          id: widget.code!.id,
          code: _codeCtrl.text.trim(),
          quantity: int.parse(_quantityCtrl.text.trim()),
          amount: int.parse(_amountCtrl.text.trim()),
          expiresAt: expiresAtStr,
        );
      } else {
        await widget.ds.createDiscountCode(
          code: _codeCtrl.text.trim(),
          quantity: int.parse(_quantityCtrl.text.trim()),
          amount: int.parse(_amountCtrl.text.trim()),
          expiresAt: expiresAtStr,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lưu thất bại, vui lòng thử lại'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          _isEdit ? 'Cập nhật mã giảm giá' : 'Tạo mã giảm giá',
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration('Mã giảm giá *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập mã giảm giá' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Số lượng *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nhập số lượng';
                if (int.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Số tiền giảm (¥) *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nhập số tiền giảm';
                if (int.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _expiresAt != null
                            ? '${_expiresAt!.day.toString().padLeft(2, '0')}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.year}'
                            : 'Ngày hết hạn *',
                        style: TextStyle(
                          fontSize: 14,
                          color: _expiresAt != null
                              ? AppColors.black
                              : AppColors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isEdit ? 'Cập nhật' : 'Tạo mã',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
