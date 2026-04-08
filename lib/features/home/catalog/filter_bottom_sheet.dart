import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/home/data/models/brand_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<BrandModel> brands;
  final int? selectedCategoryId;
  final int? selectedBrandId;
  final String? selectedGender;
  final String? selectedMovementType;
  final String? selectedStockType;
  final int? selectedIsNew;

  const FilterBottomSheet({
    super.key,
    required this.brands,
    this.selectedCategoryId,
    this.selectedBrandId,
    this.selectedGender,
    this.selectedMovementType,
    this.selectedStockType,
    this.selectedIsNew,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String? _selectedGender;
  String? _selectedMovementType;
  String? _selectedStockType;
  int? _selectedIsNew;

  bool get _isWatchCategory =>
      _selectedCategoryId == null || _selectedCategoryId == 1;

  static const _categories = [
    _FilterOption(value: '1', label: 'Đồng hồ'),
    _FilterOption(value: '2', label: 'Laptop'),
    _FilterOption(value: '3', label: 'Macbook'),
    _FilterOption(value: '4', label: 'iPad'),
  ];

  static const _branches = [
    _FilterOption(value: '1', label: 'Orient Star'),
    _FilterOption(value: '2', label: 'Orient'),
    _FilterOption(value: '3', label: 'Citizen'),
    _FilterOption(value: '4', label: 'Seiko'),
    _FilterOption(value: '5', label: 'Carnival'),
    _FilterOption(value: '6', label: 'Longines'),
    _FilterOption(value: '7', label: 'Tissot'),
    _FilterOption(value: '8', label: 'Omega'),
    _FilterOption(value: '11', label: 'Đồng hồ khác'),
  ];

  static const _genders = [
    _FilterOption(value: 'male', label: 'Nam'),
    _FilterOption(value: 'female', label: 'Nữ'),
    _FilterOption(value: 'couple', label: 'Cặp đôi'),
  ];

  static const _movementTypes = [
    _FilterOption(value: 'quartz', label: 'Quartz (Pin)'),
    _FilterOption(value: 'automatic', label: 'Automatic'),
    _FilterOption(value: 'manual', label: 'Manual'),
    _FilterOption(value: 'solar', label: 'Solar'),
    _FilterOption(value: 'kinetic', label: 'Kinetic'),
  ];

  static const _conditions = [
    _FilterOption(value: '1', label: 'Mới'),
    _FilterOption(value: '0', label: 'Cũ'),
  ];

  static const _stockTypes = [
    _FilterOption(value: 'in_stock', label: 'Có sẵn'),
    _FilterOption(value: 'pre_order', label: 'Đặt trước'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedBrandId = widget.selectedBrandId;
    _selectedGender = widget.selectedGender;
    _selectedMovementType = widget.selectedMovementType;
    _selectedStockType = widget.selectedStockType;
    _selectedIsNew = widget.selectedIsNew;
  }

  int get _filterCount {
    int count = 0;
    if (_selectedCategoryId != null) count++;
    if (_selectedBrandId != null) count++;
    if (_selectedGender != null) count++;
    if (_selectedMovementType != null) count++;
    if (_selectedStockType != null) count++;
    if (_selectedIsNew != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onTap: () {}, // absorb taps on sheet content
        child: Container(
      margin: const EdgeInsets.only(top: 120),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Danh mục ──
                  _buildSectionTitle('Danh mục'),
                  const SizedBox(height: 12),
                  _buildPillGroup(
                    options: _categories,
                    selectedValue: _selectedCategoryId?.toString(),
                    onSelect: (v) {
                      setState(() {
                        _selectedCategoryId =
                            v != null ? int.parse(v) : null;
                        if (!_isWatchCategory) {
                          _selectedBrandId = null;
                          _selectedGender = null;
                          _selectedMovementType = null;
                          _selectedStockType = null;
                          _selectedIsNew = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Thương hiệu (chỉ hiện khi đồng hồ) ──
                  if (_isWatchCategory) ...[
                    _buildSectionTitle('Thương hiệu'),
                    const SizedBox(height: 12),
                    _buildPillGroup(
                      options: _branches,
                      selectedValue: _selectedBrandId?.toString(),
                      onSelect: (v) => setState(() {
                        _selectedBrandId = v != null ? int.parse(v) : null;
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Giới tính (chỉ hiện khi đồng hồ) ──
                  if (_isWatchCategory) ...[
                    _buildSectionTitle('Giới tính'),
                    const SizedBox(height: 12),
                    _buildPillGroup(
                      options: _genders,
                      selectedValue: _selectedGender,
                      onSelect: (v) => setState(() => _selectedGender = v),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Phân loại (cũ/mới, chỉ hiện khi đồng hồ) ──
                  if (_isWatchCategory) ...[
                    _buildSectionTitle('Phân loại'),
                    const SizedBox(height: 12),
                    _buildPillGroup(
                      options: _conditions,
                      selectedValue: _selectedIsNew?.toString(),
                      onSelect: (v) => setState(() {
                        _selectedIsNew = v != null ? int.parse(v) : null;
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Loại máy (chỉ hiện khi đồng hồ) ──
                  if (_isWatchCategory) ...[
                    _buildSectionTitle('Loại máy'),
                    const SizedBox(height: 12),
                    _buildPillGroup(
                      options: _movementTypes,
                      selectedValue: _selectedMovementType,
                      onSelect: (v) =>
                          setState(() => _selectedMovementType = v),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Tình trạng kho (chỉ hiện khi đồng hồ) ──
                  if (_isWatchCategory) ...[
                    _buildSectionTitle('Tình trạng'),
                    const SizedBox(height: 12),
                    _buildPillGroup(
                      options: _stockTypes,
                      selectedValue: _selectedStockType,
                      onSelect: (v) => setState(() => _selectedStockType = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SafeArea(
              child: Row(
                children: [
                  // Reset button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = null;
                            _selectedBrandId = null;
                            _selectedGender = null;
                            _selectedMovementType = null;
                            _selectedStockType = null;
                            _selectedIsNew = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.greyLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'category_id': _selectedCategoryId,
                            'brand_id': _selectedBrandId,
                            'gender': _selectedGender,
                            'movement_type': _selectedMovementType,
                            'stock_type': _selectedStockType,
                            'is_new': _selectedIsNew,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Áp dụng${_filterCount > 0 ? ' ($_filterCount)' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildPillGroup({
    required List<_FilterOption> options,
    required String? selectedValue,
    required ValueChanged<String?> onSelect,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : option.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.black : AppColors.greyLight,
              ),
            ),
            child: Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterOption {
  final String value;
  final String label;
  const _FilterOption({required this.value, required this.label});
}
