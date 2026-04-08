import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/auth_guard.dart';
import 'package:sgwatch_app/core/widgets/floating_social_buttons.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorites_screen.dart';
import 'package:sgwatch_app/features/home/presentation/home_screen.dart';
import 'package:sgwatch_app/features/notifications/presentation/notifications_screen.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  /// Tabs that require authentication (index > 0)
  static const _authRequiredTabs = {1, 2, 3};

  Future<void> _onTabTap(int index) async {
    if (index == _currentIndex) return;

    if (_authRequiredTabs.contains(index)) {
      final isAuth = await AuthGuard.check(context);
      if (!isAuth) return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_screens[_currentIndex], const FloatingSocialButtons()],
      ),
      bottomNavigationBar: Container(
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
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'Trang chủ', 0),
                _buildNavItem(Icons.favorite_outline, 'Yêu thích', 1),
                _buildNavItem(Icons.notifications_none, 'Thông báo', 2),
                _buildNavItem(Icons.person_outline, 'Tài khoản', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.black : AppColors.grey;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
