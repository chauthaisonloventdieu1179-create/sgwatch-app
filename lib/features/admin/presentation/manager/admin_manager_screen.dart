import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_all_orders_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_blog_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_discount_codes_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_inventory_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_notification_create_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_processing_orders_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_product_list_screen.dart';

class AdminManagerScreen extends StatelessWidget {
  const AdminManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Quản lý',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionTitle('Đơn hàng'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    title: 'Đang xử lý / Xác nhận',
                    subtitle: 'Đơn processing & confirmed',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AdminProcessingOrdersScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.list_alt,
                    color: AppColors.primary,
                    title: 'Tất cả đơn hàng',
                    subtitle: 'Xem & quản lý đơn',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminAllOrdersScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Kho hàng'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    color: Colors.teal,
                    title: 'Hàng tồn kho',
                    subtitle: 'Hàng đi & hàng nhập',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminInventoryScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.notifications_active_outlined,
                    color: Colors.indigo,
                    title: 'Thêm thông báo',
                    subtitle: 'Gửi thông báo mới',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AdminNotificationCreateScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Khuyến mãi'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.discount_outlined,
                    color: Colors.deepOrange,
                    title: 'Mã giảm giá',
                    subtitle: 'Tạo & quản lý mã',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminDiscountCodesScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.article_outlined,
                    color: Colors.teal,
                    title: 'Quản lý Blog',
                    subtitle: 'Xem & quản lý bài viết',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminBlogScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Sản phẩm'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.watch_outlined,
                    color: Colors.brown,
                    title: 'Đồng hồ',
                    subtitle: 'Quản lý sản phẩm',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminProductListScreen(
                              categoryId: 1,
                              categoryName: 'Đồng hồ')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.laptop_outlined,
                    color: Colors.blue,
                    title: 'Laptop',
                    subtitle: 'Quản lý sản phẩm',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminProductListScreen(
                              categoryId: 2,
                              categoryName: 'Laptop')),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.computer_outlined,
                    color: Colors.grey.shade700,
                    title: 'MacBook',
                    subtitle: 'Quản lý sản phẩm',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminProductListScreen(
                              categoryId: 3,
                              categoryName: 'MacBook')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.tablet_outlined,
                    color: Colors.purple,
                    title: 'iPad',
                    subtitle: 'Quản lý sản phẩm',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminProductListScreen(
                              categoryId: 4,
                              categoryName: 'iPad')),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
