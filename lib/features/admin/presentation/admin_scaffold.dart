import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/presentation/chat/admin_chat_list_screen.dart';
import 'package:sgwatch_app/features/admin/presentation/manager/admin_manager_screen.dart';
import 'package:sgwatch_app/features/home/presentation/home_screen.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_screen.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int _currentIndex = 0;
  final _chatUnread = ValueNotifier<int>(0);
  Timer? _unreadTimer;
  final _ds = AdminDatasource(ApiClient());

  @override
  void initState() {
    super.initState();
    _fetchUnread();
    _unreadTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _fetchUnread(),
    );
  }

  Future<void> _fetchUnread() async {
    try {
      final count = await _ds.getUnreadCount();
      _chatUnread.value = count;
    } catch (_) {}
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    _chatUnread.dispose();
    super.dispose();
  }

  Widget _getScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AdminManagerScreen();
      case 2:
        return const AdminChatListScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    if (index == 2) {
      // Clear chat unread when entering chat
      _chatUnread.value = 0;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(),
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
                _buildNavItem(Icons.dashboard_outlined, 'Quản lý', 1),
                ValueListenableBuilder<int>(
                  valueListenable: _chatUnread,
                  builder: (_, count, __) =>
                      _buildNavItem(Icons.chat_outlined, 'Chat', 2,
                          badge: count),
                ),
                _buildNavItem(Icons.person_outline, 'Tài khoản', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {int badge = 0}) {
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 26, color: color),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
