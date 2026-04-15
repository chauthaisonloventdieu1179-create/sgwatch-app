import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_product_model.dart';

class AdminProductFormScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int? productId; // null = create, non-null = edit

  const AdminProductFormScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.productId,
  });

  @override
  State<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _ds = AdminDatasource(ApiClient());
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _warrantyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _productInfoCtrl = TextEditingController();
  final _dealInfoCtrl = TextEditingController();
  final _thongSoCtrl = TextEditingController();
  final _colorCodeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _displayOrderCtrl = TextEditingController();

  // State
  String _stockType = 'in_stock';
  bool _isNew = true;
  bool _isDomestic = false;
  String? _gender;
  String? _movementType;
  int? _selectedBrandId;

  List<AdminBrandModel> _brands = [];
  final List<File> _newImages = [];
  List<AdminProductImageModel> _existingImages = [];
  final List<int> _deletedImageIds = [];

  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isWatch =>
      widget.categoryName.toLowerCase().contains('đồng hồ') ||
      widget.categoryName.toLowerCase().contains('clock') ||
      widget.categoryId == 1;

  bool get _isCarnival => _selectedBrandId == 5;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    if (widget.productId != null) _loadProduct();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _pointsCtrl.dispose();
    _stockCtrl.dispose();
    _warrantyCtrl.dispose();
    _descCtrl.dispose();
    _productInfoCtrl.dispose();
    _dealInfoCtrl.dispose();
    _thongSoCtrl.dispose();
    _colorCodeCtrl.dispose();
    _colorCtrl.dispose();
    _displayOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _ds.getBrands();
      setState(() => _brands = brands);
    } catch (_) {}
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final p = await _ds.getProductDetail(widget.productId!);
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku ?? '';
      _priceCtrl.text = p.priceJpy.toString();
      _originalPriceCtrl.text = p.originalPriceJpy?.toString() ?? '';
      _costPriceCtrl.text = p.costPriceJpy?.toString() ?? '';
      _pointsCtrl.text = p.points?.toString() ?? '';
      _stockCtrl.text = p.stockQuantity.toString();
      _warrantyCtrl.text = p.warrantyMonths?.toString() ?? '';
      _descCtrl.text = p.description ?? '';
      _productInfoCtrl.text = p.productInfo ?? '';
      _dealInfoCtrl.text = p.dealInfo ?? '';
      _thongSoCtrl.text = p.attributes?['thong_so_ky_thuat']?.toString() ?? '';
      _colorCodeCtrl.text = p.attributes?['color_code']?.toString() ?? '';
      _colorCtrl.text = p.attributes?['color']?.toString() ?? '';
      _displayOrderCtrl.text = p.displayOrder?.toString() ?? '';
      setState(() {
        _stockType = p.stockType;
        _isNew = p.isNew;
        _isDomestic = p.isDomestic;
        _gender = p.gender;
        _movementType = p.movementType;
        _selectedBrandId = p.brandId;
        _existingImages = p.images;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      for (final f in picked) {
        _newImages.add(File(f.path));
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final map = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'category_id': widget.categoryId,
        'stock_quantity': _stockCtrl.text.trim(),
        'stock_type': _stockType,
        'is_new': _isNew ? 1 : 0,
        'is_domestic': _isDomestic ? 1 : 0,
      };

      if (_skuCtrl.text.trim().isNotEmpty) {
        map['sku'] = _skuCtrl.text.trim();
      }
      if (_priceCtrl.text.trim().isNotEmpty) {
        map['price_jpy'] = _priceCtrl.text.trim();
      }
      if (_originalPriceCtrl.text.trim().isNotEmpty) {
        map['original_price_jpy'] = _originalPriceCtrl.text.trim();
      }
      if (_costPriceCtrl.text.trim().isNotEmpty) {
        map['cost_price_jpy'] = _costPriceCtrl.text.trim();
      }
      if (_pointsCtrl.text.trim().isNotEmpty) {
        map['points'] = _pointsCtrl.text.trim();
      }
      if (_selectedBrandId != null) map['brand_id'] = _selectedBrandId;
      if (_gender != null) map['gender'] = _gender;
      if (_movementType != null) map['movement_type'] = _movementType;
      if (_warrantyCtrl.text.trim().isNotEmpty) {
        map['warranty_months'] = _warrantyCtrl.text.trim();
      }
      if (_thongSoCtrl.text.trim().isNotEmpty) {
        map['attributes[thong_so_ky_thuat]'] = _thongSoCtrl.text.trim();
      }
      if (_isCarnival) {
        if (_colorCodeCtrl.text.trim().isNotEmpty) {
          map['attributes[color_code]'] = _colorCodeCtrl.text.trim();
        }
        if (_colorCtrl.text.trim().isNotEmpty) {
          map['attributes[color]'] = _colorCtrl.text.trim();
        }
      }
      if (_descCtrl.text.trim().isNotEmpty) {
        map['description'] = _descCtrl.text.trim();
      }
      if (_productInfoCtrl.text.trim().isNotEmpty) {
        map['product_info'] = _productInfoCtrl.text.trim();
      }
      if (_dealInfoCtrl.text.trim().isNotEmpty) {
        map['deal_info'] = _dealInfoCtrl.text.trim();
      }
      if (_displayOrderCtrl.text.trim().isNotEmpty) {
        map['display_order'] = _displayOrderCtrl.text.trim();
      }

      // New images
      for (int i = 0; i < _newImages.length; i++) {
        map['images[$i]'] = await MultipartFile.fromFile(
          _newImages[i].path,
          filename: _newImages[i].path.split('/').last,
        );
      }

      // Deleted images (edit mode)
      for (int i = 0; i < _deletedImageIds.length; i++) {
        map['delete_images[$i]'] = _deletedImageIds[i];
      }

      final formData = FormData.fromMap(map);

      if (widget.productId != null) {
        await _ds.updateProduct(widget.productId!, formData);
      } else {
        await _ds.createProduct(formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId != null
                ? 'Cập nhật sản phẩm thành công'
                : 'Thêm sản phẩm thành công'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi lưu sản phẩm')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;
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
          isEdit
              ? 'Sửa ${widget.categoryName}'
              : 'Thêm ${widget.categoryName}',
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppColors.white, strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Lưu',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection('Thông tin cơ bản', [
                    _buildTextField(_nameCtrl, 'Tên sản phẩm *',
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Bắt buộc'
                                : null),
                    const SizedBox(height: 12),
                    _buildTextField(_skuCtrl, 'SKU *',
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Bắt buộc'
                                : null),
                    const SizedBox(height: 12),
                    if (_brands.isNotEmpty) ...[
                      DropdownButtonFormField<int?>(
                        value: _selectedBrandId,
                        decoration: _inputDecoration('Thương hiệu'),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('-- Chọn thương hiệu --'),
                          ),
                          ..._brands.map((b) => DropdownMenuItem<int?>(
                                value: b.id,
                                child: Text(b.name),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedBrandId = v),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('Giá', [
                    _buildTextField(
                      _priceCtrl,
                      'Giá bán (JPY) *',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _originalPriceCtrl,
                      'Giá gốc (JPY)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _costPriceCtrl,
                      'Giá nhập (JPY)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _pointsCtrl,
                      'Điểm tích lũy',
                      keyboardType: TextInputType.number,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('Kho hàng', [
                    _buildTextField(
                      _stockCtrl,
                      'Số lượng *',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _stockType,
                      decoration: _inputDecoration('Loại kho'),
                      items: const [
                        DropdownMenuItem(
                            value: 'in_stock', child: Text('Hàng có sẵn')),
                        DropdownMenuItem(
                            value: 'pre_order', child: Text('Hàng order')),
                      ],
                      onChanged: (v) =>
                          setState(() => _stockType = v ?? 'in_stock'),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitch('Hàng mới', _isNew,
                        (v) => setState(() => _isNew = v)),
                    _buildSwitch('Hàng nội địa Nhật', _isDomestic,
                        (v) => setState(() => _isDomestic = v)),
                  ]),
                  if (_isWatch) ...[
                    const SizedBox(height: 12),
                    _buildSection('Đặc tính đồng hồ', [
                      DropdownButtonFormField<String?>(
                        value: _gender,
                        decoration: _inputDecoration('Giới tính'),
                        items: const [
                          DropdownMenuItem<String?>(
                              value: null, child: Text('-- Chọn --')),
                          DropdownMenuItem(
                              value: 'male', child: Text('Nam')),
                          DropdownMenuItem(
                              value: 'female', child: Text('Nữ')),
                          DropdownMenuItem(
                              value: 'couple',
                              child: Text('Đồng hồ cặp')),
                          DropdownMenuItem(
                              value: 'unisex', child: Text('Unisex')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        value: _movementType,
                        decoration: _inputDecoration('Bộ máy'),
                        items: const [
                          DropdownMenuItem<String?>(
                              value: null, child: Text('-- Chọn --')),
                          DropdownMenuItem(
                              value: 'automatic',
                              child: Text('Automatic')),
                          DropdownMenuItem(
                              value: 'quartz',
                              child: Text('Quartz (Pin)')),
                          DropdownMenuItem(
                              value: 'manual', child: Text('Manual')),
                          DropdownMenuItem(
                              value: 'solar', child: Text('Solar')),
                        ],
                        onChanged: (v) =>
                            setState(() => _movementType = v),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _warrantyCtrl,
                        'Bảo hành (tháng)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _thongSoCtrl,
                        'Thông số kỹ thuật',
                        maxLines: 5,
                      ),
                    ]),
                  ],
                  if (_isCarnival) ...[
                    const SizedBox(height: 12),
                    _buildSection('Carnival - Màu sắc', [
                      _buildTextField(
                          _colorCodeCtrl, 'Mã màu (Color Code)'),
                      const SizedBox(height: 12),
                      _buildTextField(_colorCtrl, 'Màu (mô tả)'),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  _buildSection('Mô tả', [
                    _buildTextField(_descCtrl, 'Mô tả sản phẩm',
                        maxLines: 4),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _productInfoCtrl, 'Thông tin sản phẩm',
                        maxLines: 4),
                    const SizedBox(height: 12),
                    _buildTextField(_dealInfoCtrl, 'Thông tin deal',
                        maxLines: 3),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('Hiển thị', [
                    _buildTextField(
                      _displayOrderCtrl,
                      'Thứ tự hiển thị',
                      keyboardType: TextInputType.number,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEdit ? 'Cập nhật' : 'Thêm sản phẩm',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
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
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
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
          const Text('Hình ảnh',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Existing images
              ..._existingImages.map((img) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          img.url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.backgroundGrey,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.grey),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _deletedImageIds.add(img.id);
                              _existingImages.remove(img);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                size: 16, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  )),
              // New images
              ..._newImages.asMap().entries.map((e) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          e.value,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _newImages.removeAt(e.key)),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                size: 16, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  )),
              // Add button
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.grey),
                      Text('Thêm',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.black)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      filled: true,
      fillColor: AppColors.backgroundGrey,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
