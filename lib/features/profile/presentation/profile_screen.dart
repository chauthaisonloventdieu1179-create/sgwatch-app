import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/admin_mode.dart';
import 'package:sgwatch_app/features/auth/presentation/login_screen.dart';
import 'package:sgwatch_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_viewmodel.dart';
import 'package:sgwatch_app/features/address/presentation/address_list_screen.dart';
import 'package:sgwatch_app/features/store_info/presentation/store_info_screen.dart';
import 'package:sgwatch_app/features/orders/presentation/orders_screen.dart';
import 'package:sgwatch_app/features/support/presentation/support_screen.dart';
import 'package:sgwatch_app/features/warranty/presentation/warranty_policy_screen.dart';
import 'package:sgwatch_app/features/warranty/presentation/laptop_warranty_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadUserData();
    _viewModel.loadUserPoint();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await _viewModel.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildMenuCard(),
              const SizedBox(height: 24),
              _buildAppSettings(),
              if (_viewModel.user?.role == 'admin') ...[
                const SizedBox(height: 24),
                _buildAdminToggle(),
              ],
              const SizedBox(height: 24),
              _buildLogout(),
              const SizedBox(height: 12),
              _buildDeleteAccount(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.greyLight,
          backgroundImage:
              _viewModel.avatarUrl != null ? NetworkImage(_viewModel.avatarUrl!) : null,
          child: _viewModel.avatarUrl == null
              ? const Icon(Icons.person, color: AppColors.grey, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _viewModel.userName.isNotEmpty ? _viewModel.userName : '---',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  user: _viewModel.user,
                  viewModel: _viewModel,
                ),
              ),
            );
            if (result == true) {
              _viewModel.loadUserData();
            }
          },
          icon: const Icon(Icons.edit_outlined, color: AppColors.black),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionItem(
            Icons.receipt_long_outlined,
            'Đơn hàng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
          _buildQuickActionItem(
            Icons.location_on_outlined,
            'Địa chỉ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 98,
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
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
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.square_rounded,
            iconColor: AppColors.greyPlaceholder,
            title: 'Point',
            subtitle: '${_viewModel.point} pt',
            showDivider: true,
            onTap: () {},
          ),
          // _buildMenuItem(
          //   icon: Icons.confirmation_number_outlined,
          //   title: 'Mã giảm giá',
          //   showDivider: true,
          //   onTap: () {},
          // ),
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: 'Hỗ trợ',
            showDivider: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: 'Thông tin cửa hàng',
            showDivider: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreInfoScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.watch_outlined,
            title: 'Chính sách bảo hành đồng hồ',
            showDivider: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const WarrantyPolicyScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.laptop_outlined,
            title: 'Chính sách bảo hành & HDSD laptop',
            showDivider: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LaptopWarrantyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    required bool showDivider,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 30, color: iconColor ?? AppColors.black),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.greyLight),
          ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt ứng dụng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Row(
            children: [
              const Icon(Icons.notifications_none, size: 30, color: AppColors.black),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              Switch(
                value: _viewModel.notificationEnabled,
                onChanged: (value) => _viewModel.toggleNotification(value),
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bạn có chắc chắn muốn\nxóa tài khoản ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tài khoản của bạn sẽ bị xóa vĩnh viễn\ntrên mọi nền tảng',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Xác nhận', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEEEEE),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Hủy bỏ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    await _viewModel.deleteAccount();

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildDeleteAccount() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: InkWell(
        onTap: _handleDeleteAccount,
        child: const Row(
          children: [
            Icon(Icons.delete_outline, size: 30, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Xóa tài khoản',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: AdminMode.notifier,
      builder: (_, isAdmin, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 4,
                offset: Offset(1, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Chế độ Admin',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black)),
            ),
            Switch(
              value: isAdmin,
              onChanged: (v) => AdminMode.setAdminMode(v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout() {
    return Container(
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
      child: InkWell(
        onTap: _handleLogout,
        child: const Row(
          children: [
            Icon(Icons.logout, size: 30, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
