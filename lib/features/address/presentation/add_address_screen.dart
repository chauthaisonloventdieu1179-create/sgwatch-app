import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/address/data/models/address_model.dart';
import 'package:sgwatch_app/features/address/presentation/address_viewmodel.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressViewModel viewModel;
  final AddressModel? editAddress;

  const AddAddressScreen({
    super.key,
    required this.viewModel,
    this.editAddress,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  static const _countries = [
    {'label': 'Nhật Bản', 'code': 'JP'},
    {'label': 'Việt Nam', 'code': 'VN'},
  ];

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Common
  late final TextEditingController _labelController;
  late String _countryCode;
  late bool _showDetailFields;

  // Detail fields (shared between JP & VN, mapped differently)
  late final TextEditingController _postalCodeController;
  late final TextEditingController
  _field1Controller; // JP: prefecture, VN: province_city
  late final TextEditingController _field2Controller; // JP: city, VN: district
  late final TextEditingController
  _field3Controller; // JP: ward_town, VN: ward_commune
  late final TextEditingController
  _field4Controller; // JP: banchi, VN: detail_address
  late final TextEditingController _buildingNameController;
  late final TextEditingController _roomNoController;
  late final TextEditingController _phoneController;

  // Image
  String? _existingImageUrl;
  File? _pickedImageFile;

  bool get _isEditing => widget.editAddress != null;
  bool get _isJp => _countryCode == 'JP';

  String get _countryLabel =>
      _countries.firstWhere((c) => c['code'] == _countryCode)['label']!;

  @override
  void initState() {
    super.initState();
    final addr = widget.editAddress;

    _labelController = TextEditingController(text: addr?.label ?? '');
    _countryCode = addr?.countryCode ?? 'JP';
    _postalCodeController = TextEditingController(text: addr?.postalCode ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _existingImageUrl = addr?.imageUrl;

    // Populate detail fields from JP or VN sub-object
    if (addr?.jpDetail != null) {
      final jp = addr!.jpDetail!;
      _field1Controller = TextEditingController(text: jp.prefecture);
      _field2Controller = TextEditingController(text: jp.wardTown);
      _field3Controller = TextEditingController(text: jp.banchi);
      _field4Controller = TextEditingController();
      _buildingNameController = TextEditingController(
        text: jp.buildingName ?? '',
      );
      _roomNoController = TextEditingController(text: jp.roomNo ?? '');
    } else if (addr?.vnDetail != null) {
      final vn = addr!.vnDetail!;
      _field1Controller = TextEditingController(text: vn.provinceCity);
      _field2Controller = TextEditingController(text: vn.district);
      _field3Controller = TextEditingController(text: vn.wardCommune);
      _field4Controller = TextEditingController(text: vn.detailAddress);
      _buildingNameController = TextEditingController(
        text: vn.buildingName ?? '',
      );
      _roomNoController = TextEditingController(text: vn.roomNo ?? '');
    } else {
      _field1Controller = TextEditingController();
      _field2Controller = TextEditingController();
      _field3Controller = TextEditingController();
      _field4Controller = TextEditingController();
      _buildingNameController = TextEditingController();
      _roomNoController = TextEditingController();
    }

    // Determine toggle state
    if (addr != null) {
      _showDetailFields = addr.inputMode == 'manual';
    } else {
      // Bắt buộc nhập chi tiết cho cả JP và VN
      _showDetailFields = true;
    }

    // Auto-lookup khi nhập đủ 7 số mã bưu điện (JP)
    _postalCodeController.addListener(_onPostalCodeChanged);

    // Fetch address data based on country
    if (_isJp) {
      _initJpPrefectures();
    } else {
      _initVnAddress();
    }
  }

  bool _isLookingUpZip = false;
  // Pending zipcode result — used when prefectures haven't loaded yet
  String? _pendingZipPrefName;

  // JP prefectures data
  List<Map<String, dynamic>> _jpPrefectures = [];
  String? _selectedPrefectureId;
  bool _isLoadingJpPref = false;

  Future<void> _initJpPrefectures() async {
    setState(() => _isLoadingJpPref = true);
    try {
      final list = await widget.viewModel.fetchPrefectures();
      if (!mounted) return;
      setState(() {
        _jpPrefectures = list;
        _isLoadingJpPref = false;
      });
      // If editing, pre-select existing prefecture
      if (_isEditing && widget.editAddress?.jpDetail?.prefectureId != null) {
        _selectedPrefectureId = widget.editAddress!.jpDetail!.prefectureId;
      }
      // If zipcode was looked up before prefectures loaded, match now
      if (_pendingZipPrefName != null && _selectedPrefectureId == null) {
        final match = list
            .where((p) => p['name']?.toString() == _pendingZipPrefName)
            .firstOrNull;
        if (match != null) {
          setState(() {
            _selectedPrefectureId = match['prefecture_id']?.toString();
          });
        }
        _pendingZipPrefName = null;
      }
    } catch (e) {
      debugPrint('[Address] Fetch prefectures error: $e');
      if (mounted) setState(() => _isLoadingJpPref = false);
    }
  }

  void _onPrefectureSelected(Map<String, dynamic> pref) {
    setState(() {
      _selectedPrefectureId = pref['prefecture_id']?.toString();
      _field1Controller.text = pref['name']?.toString() ?? '';
    });
  }

  void _showJpPrefecturePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String searchText = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = searchText.isEmpty
                ? _jpPrefectures
                : _jpPrefectures
                      .where(
                        (p) => (p['name']?.toString() ?? '')
                            .toLowerCase()
                            .contains(searchText.toLowerCase()),
                      )
                      .toList();
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.3,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '都道府県 (Tỉnh)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        onChanged: (v) => setSheetState(() => searchText = v),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.greyLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final id = item['prefecture_id']?.toString();
                          final isSelected = id == _selectedPrefectureId;
                          return ListTile(
                            title: Text(item['name']?.toString() ?? ''),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(ctx);
                              _onPrefectureSelected(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // VN provinces API data
  List<Map<String, dynamic>> _vnProvinces = [];
  int? _selectedProvinceCode;
  bool _isLoadingVn = false;

  void _onPostalCodeChanged() {
    if (!_isJp || !_showDetailFields) return;
    final raw = _postalCodeController.text
        .replaceAll('-', '')
        .replaceAll(' ', '');
    if (raw.length == 7 && RegExp(r'^\d{7}$').hasMatch(raw)) {
      _lookupZipcode(raw);
    }
  }

  Future<void> _lookupZipcode(String zipcode) async {
    if (_isLookingUpZip) return;
    _isLookingUpZip = true;
    debugPrint('[Address] Zipcode lookup: $zipcode');

    try {
      final response = await Dio().get(
        'https://zipcloud.ibsnet.co.jp/api/search',
        queryParameters: {'zipcode': zipcode},
      );
      final rawData = response.data;
      final data = rawData is String
          ? (json.decode(rawData) as Map<String, dynamic>)
          : rawData;
      if (data['status'] == 200 &&
          data['results'] != null &&
          (data['results'] as List).isNotEmpty) {
        final result = data['results'][0];
        final addr1 = result['address1']?.toString() ?? '';
        final addr2 = result['address2']?.toString() ?? '';
        final addr3 = result['address3']?.toString() ?? '';

        // Match prefecture name to list to get ID
        final prefMatch = _jpPrefectures
            .where((p) => p['name']?.toString() == addr1)
            .firstOrNull;

        setState(() {
          _field1Controller.text = addr1;
          _field2Controller.text = '$addr2$addr3';
          if (prefMatch != null) {
            _selectedPrefectureId = prefMatch['prefecture_id']?.toString();
            _pendingZipPrefName = null;
          } else {
            // Prefectures may not have loaded yet — save for later
            _pendingZipPrefName = addr1;
          }
        });
        debugPrint(
          '[Address] Zipcode OK: $addr1 $addr2$addr3 (prefMatch=${prefMatch != null})',
        );
      } else {
        debugPrint('[Address] Zipcode not found');
      }
    } catch (e) {
      debugPrint('[Address] Zipcode lookup error: $e');
    } finally {
      _isLookingUpZip = false;
    }
  }

  // ── VN Provinces API ─────────────────────────────────────

  Future<void> _initVnAddress() async {
    setState(() => _isLoadingVn = true);
    try {
      final response = await Dio().get('https://provinces.open-api.vn/api/v2/');
      final list = (response.data as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _vnProvinces = list;
        _isLoadingVn = false;
      });
      // If editing, pre-select existing address
      if (_isEditing) await _preSelectVnAddress();
    } catch (e) {
      debugPrint('[Address] Fetch VN provinces error: $e');
      if (mounted) setState(() => _isLoadingVn = false);
    }
  }

  Future<void> _preSelectVnAddress() async {
    final provinceRaw = _field1Controller.text.trim();
    if (provinceRaw.isEmpty) return;

    // Match province by code first, then by name as fallback
    final provinceCode = int.tryParse(provinceRaw);
    Map<String, dynamic>? pMatch;
    if (provinceCode != null) {
      pMatch = _vnProvinces.where((p) => p['code'] == provinceCode).firstOrNull;
    }
    pMatch ??= _vnProvinces.where((p) => p['name'] == provinceRaw).firstOrNull;
    if (pMatch == null) return;

    setState(() {
      _selectedProvinceCode = pMatch!['code'] as int;
      _field1Controller.text = pMatch['name'] as String;
    });
  }

  void _onProvinceSelected(Map<String, dynamic> province) {
    setState(() {
      _selectedProvinceCode = province['code'] as int;
      _field1Controller.text = province['name'] as String;
    });
  }

  void _showVnPicker({
    required String title,
    required List<Map<String, dynamic>> items,
    required int? selectedCode,
    required ValueChanged<Map<String, dynamic>> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String searchText = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = searchText.isEmpty
                ? items
                : items.where((i) {
                    final searchKey = (i['name'] as String);
                    return searchKey.toLowerCase().contains(
                      searchText.toLowerCase(),
                    );
                  }).toList();
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.3,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        onChanged: (v) => setSheetState(() => searchText = v),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.greyLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item['code'] == selectedCode;
                          final displayText = item['name'] as String;
                          return ListTile(
                            title: Text(displayText),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(ctx);
                              onSelected(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _postalCodeController.removeListener(_onPostalCodeChanged);
    _labelController.dispose();
    _postalCodeController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    _field4Controller.dispose();
    _buildingNameController.dispose();
    _roomNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String code) {
    setState(() {
      _countryCode = code;
      _field1Controller.clear();
      _field2Controller.clear();
      _field3Controller.clear();
      _field4Controller.clear();
      // Reset VN state
      _selectedProvinceCode = null;
      // Reset JP state
      _selectedPrefectureId = null;
      if (code == 'VN') {
        _showDetailFields = true;
        if (_vnProvinces.isEmpty) _initVnAddress();
      } else if (code == 'JP') {
        if (_jpPrefectures.isEmpty) _initJpPrefectures();
      }
    });
  }

  String get _inputMode {
    if (_isJp && !_showDetailFields) return 'image_only';
    return 'manual';
  }

  AddressModel _buildModel() {
    final label = _labelController.text.trim();
    final postalCode = _postalCodeController.text.trim();
    final phone = _phoneController.text.trim();

    JpDetail? jpDetail;
    VnDetail? vnDetail;

    if (_inputMode == 'manual') {
      if (_isJp) {
        jpDetail = JpDetail(
          prefectureId: _selectedPrefectureId,
          prefecture: _field1Controller.text.trim(),
          wardTown: _field2Controller.text.trim(),
          banchi: _field3Controller.text.trim(),
          buildingName: _buildingNameController.text.trim().isEmpty
              ? null
              : _buildingNameController.text.trim(),
          roomNo: _roomNoController.text.trim().isEmpty
              ? null
              : _roomNoController.text.trim(),
        );
      } else {
        vnDetail = VnDetail(
          provinceCity: _selectedProvinceCode?.toString() ?? '',
          district: '',
          wardCommune: '',
          detailAddress: _field4Controller.text.trim(),
          buildingName: _buildingNameController.text.trim().isEmpty
              ? null
              : _buildingNameController.text.trim(),
          roomNo: _roomNoController.text.trim().isEmpty
              ? null
              : _roomNoController.text.trim(),
        );
      }
    }

    return AddressModel(
      label: label,
      countryCode: _countryCode,
      inputMode: _inputMode,
      postalCode: postalCode.isEmpty ? null : postalCode,
      phone: phone.isEmpty ? null : phone,
      isDefault: widget.editAddress?.isDefault ?? false,
      jpDetail: jpDetail,
      vnDetail: vnDetail,
    );
  }

  Future<void> _pickImage() async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (xFile == null) return;

    setState(() {
      _pickedImageFile = File(xFile.path);
    });
  }

  bool get _hasImage => _pickedImageFile != null || _existingImageUrl != null;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // JP manual → require prefecture selection
    if (_isJp && _showDetailFields && _selectedPrefectureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn 都道府県 (Tỉnh).')),
      );
      return;
    }

    // VN → require province selection
    if (!_isJp && _showDetailFields) {
      if (_field1Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn Tỉnh/Thành phố.'),
          ),
        );
        return;
      }
    }

    // JP → require image (cả image_only và manual mode)
    if (_isJp && !_hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng tải lên ảnh địa chỉ bằng chữ Hán.'),
        ),
      );
      return;
    }

    final address = _buildModel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final success = _isEditing
        ? await widget.viewModel.updateAddress(
            widget.editAddress!.id!,
            address,
            imageFile: _pickedImageFile,
          )
        : await widget.viewModel.addAddress(
            address,
            imageFile: _pickedImageFile,
          );

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss spinner

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.error ?? 'Thao tác thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: const Color(0x0D000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ',
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tên địa chỉ ──
                    _buildField(
                      label: 'Tên địa chỉ giao hàng',
                      required: true,
                      controller: _labelController,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Vui lòng nhập tên địa chỉ'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Quốc gia ──
                    _buildCountryDropdown(),
                    const SizedBox(height: 30),

                    // ── Toggle chi tiết (tạm thời tắt — JP bắt buộc nhập chi tiết) ──
                    // if (_isJp && !_isEditing) ...[
                    //   _buildDetailToggle(),
                    //   const SizedBox(height: 30),
                    // ],

                    // ── Content ──
                    if (_isJp && !_showDetailFields)
                      _buildImageUploadSection()
                    else ...[
                      _buildDetailFieldsSection(),
                      if (_isJp) ...[
                        const SizedBox(height: 24),
                        _buildImageUploadSection(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // ── Country dropdown ──────────────────────────────────────

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Quốc gia/Vùng', required: true),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isEditing ? null : _showCountryPicker,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _boxDecoration(disabled: _isEditing),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _countryLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isEditing ? AppColors.grey : AppColors.black,
                    ),
                  ),
                ),
                if (!_isEditing)
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _countries.map((c) {
              return ListTile(
                title: Text(c['label']!),
                trailing: _countryCode == c['code']
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _onCountryChanged(c['code']!);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── Detail toggle (JP only, tạo mới only) ───────────────────

  // Widget _buildDetailToggle() {
  //   return Row(
  //     children: [
  //       const Text(
  //         'Địa chỉ chi tiết',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.bold,
  //           color: AppColors.black,
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       SizedBox(
  //         height: 24,
  //         child: Switch(
  //           value: _showDetailFields,
  //           onChanged: (val) => setState(() => _showDetailFields = val),
  //           activeColor: AppColors.white,
  //           activeTrackColor: AppColors.primary,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ── Image upload (JP image_only) ───────────────────────────

  Widget _buildImageUploadSection({bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tải lên ảnh địa chỉ bằng CHỮ HÁN', required: isRequired),
        const SizedBox(height: 12),
        if (_pickedImageFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _pickedImageFile!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
        ] else if (_existingImageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _existingImageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: 120,
          height: 48,
          child: ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(_hasImage ? 'Đổi ảnh' : 'Chọn ảnh'),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 48, color: AppColors.greyLight),
      ),
    );
  }

  // ── Detail fields (manual mode) ────────────────────────────

  Widget _buildDetailFieldsSection() {
    return _isJp ? _buildJpDetailFields() : _buildVnDetailFields();
  }

  Widget _buildJpDetailFields() {
    final hasPrefectures = _jpPrefectures.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: 'Mã bưu điện',
                required: true,
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('都道府県 (Tỉnh)', required: true),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: hasPrefectures ? _showJpPrefecturePicker : null,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: hasPrefectures
                            ? AppColors.white
                            : AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.greyLight,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _field1Controller.text.isEmpty
                                  ? (_isLoadingJpPref
                                        ? 'Đang tải...'
                                        : 'Chọn tỉnh')
                                  : _field1Controller.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: _field1Controller.text.isEmpty
                                    ? AppColors.greyPlaceholder
                                    : AppColors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasPrefectures)
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.grey,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildField(
          label: '市区町村 (Thành phố/Quận)',
          required: true,
          controller: _field2Controller,
          validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: '番地 (Số nhà)',
          required: true,
          controller: _field3Controller,
          validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
        ),
        const SizedBox(height: 16),
        _buildField(label: 'Tên tòa nhà', controller: _buildingNameController),
        const SizedBox(height: 16),
        _buildField(label: 'Số phòng', controller: _roomNoController),
        const SizedBox(height: 16),
        _buildField(
          label: 'Số điện thoại',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildVnDetailFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tỉnh / Thành phố
        _buildVnDropdownField(
          label: 'Tỉnh / Thành phố',
          controller: _field1Controller,
          items: _vnProvinces,
          selectedCode: _selectedProvinceCode,
          emptyHint: _isLoadingVn ? 'Đang tải...' : 'Chọn tỉnh/thành phố',
          onSelected: _onProvinceSelected,
        ),
        const SizedBox(height: 16),
        // Địa chỉ chi tiết
        _buildField(
          label: 'Địa chỉ chi tiết',
          required: true,
          controller: _field4Controller,
          validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
        ),
        const SizedBox(height: 16),
        _buildField(label: 'Tên tòa nhà', controller: _buildingNameController),
        const SizedBox(height: 16),
        _buildField(label: 'Số phòng', controller: _roomNoController),
        const SizedBox(height: 16),
        _buildField(
          label: 'Số điện thoại',
          required: true,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
        ),
      ],
    );
  }

  Widget _buildVnDropdownField({
    required String label,
    required TextEditingController controller,
    required List<Map<String, dynamic>> items,
    required int? selectedCode,
    required String emptyHint,
    required ValueChanged<Map<String, dynamic>> onSelected,
  }) {
    final hasItems = items.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: true),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: hasItems
              ? () => _showVnPicker(
                  title: label,
                  items: items,
                  selectedCode: selectedCode,
                  onSelected: onSelected,
                )
              : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: hasItems ? AppColors.white : AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.greyLight, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? emptyHint : controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.text.isEmpty
                          ? AppColors.greyPlaceholder
                          : AppColors.black,
                    ),
                  ),
                ),
                if (hasItems)
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared UI helpers ──────────────────────────────────────

  Widget _buildLabel(String text, {bool required = false}) {
    if (!required) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$text ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const TextSpan(
            text: '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16, color: AppColors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.greyPlaceholder),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: AppColors.black),
            errorBorder: _inputBorder(color: AppColors.primary),
            focusedErrorBorder: _inputBorder(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder({Color color = AppColors.greyLight}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  BoxDecoration _boxDecoration({bool disabled = false}) {
    return BoxDecoration(
      color: disabled ? AppColors.backgroundGrey : AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.greyLight, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4,
          offset: Offset(1, 2),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: widget.viewModel.isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.greyLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: widget.viewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Xong'),
          ),
        ),
      ),
    );
  }
}
