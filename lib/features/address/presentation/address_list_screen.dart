import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/address/data/datasources/address_remote_datasource.dart';
import 'package:sgwatch_app/features/address/presentation/add_address_screen.dart';
import 'package:sgwatch_app/features/address/presentation/address_viewmodel.dart';
import 'package:sgwatch_app/features/address/presentation/widgets/address_card.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late final AddressViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final datasource = AddressRemoteDatasource(ApiClient());
    _viewModel = AddressViewModel(datasource);
    _viewModel.addListener(_onChanged);
    _viewModel.loadAddresses();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(viewModel: _viewModel),
      ),
    );
    if (result == true) {
      // Address was added, list auto-updates via viewModel
    }
  }

  Future<void> _navigateToEditAddress(int index) async {
    final address = _viewModel.addresses[index];
    if (address.id == null) return;

    // Fetch full detail from API
    final detail = await _viewModel.getAddressDetail(address.id!);
    if (!mounted || detail == null) {
      if (mounted && _viewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(
          viewModel: _viewModel,
          editAddress: detail,
        ),
      ),
    );
    if (result == true) {
      // Address was updated, reload list
      _viewModel.loadAddresses();
    }
  }

  Future<void> _confirmDelete(int index) async {
    final address = _viewModel.addresses[index];
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Xóa địa chỉ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bạn có chắc muốn xóa địa chỉ này?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        side: const BorderSide(color: AppColors.greyLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Xóa'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true && address.id != null) {
      _viewModel.deleteAddress(address.id!);
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
        title: const Text(
          'Địa chỉ',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Address list
                  ..._buildAddressList(),
                  // "Thêm địa chỉ lưu mới" button card
                  _buildAddButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _navigateToAddAddress,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 30, color: AppColors.black),
            SizedBox(width: 10),
            Text(
              'Thêm địa chỉ lưu mới',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAddressList() {
    return _viewModel.addresses.asMap().entries.map((entry) {
      final index = entry.key;
      final address = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AddressCard(
          address: address,
          onTap: () => _navigateToEditAddress(index),
          onDelete: () => _confirmDelete(index),
        ),
      );
    }).toList();
  }
}
