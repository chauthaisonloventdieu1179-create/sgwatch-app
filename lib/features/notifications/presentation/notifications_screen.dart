import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/services/notification_unread_service.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/features/notifications/data/models/notification_model.dart';
import 'package:sgwatch_app/features/notifications/presentation/notification_viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationViewModel _viewModel;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationViewModel();
    _viewModel.addListener(_onChanged);
    _scrollController.addListener(_onScroll);
    _viewModel.loadNotifications();
    // User đã vào trang thông báo → xóa badge
    NotificationUnreadService.instance.clearAll();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.maxScrollExtent > 0 &&
        pos.pixels >= pos.maxScrollExtent * 0.5) {
      _viewModel.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildAppBar(context),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTabs(),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────
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
      child: const Center(
        child: Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  // ── Tabs ───────────────────────────────────────────────────
  Widget _buildTabs() {
    const tabLabels = ['Đơn hàng', 'Hệ thống'];
    const tabIcons = [Icons.receipt_long_outlined, Icons.campaign_outlined];
    return Row(
      children: List.generate(2, (index) {
        final isSelected = _viewModel.selectedTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => _viewModel.selectTab(index),
            child: Container(
              height: 48,
              margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.black : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.greyPlaceholder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tabIcons[index],
                    size: 20,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tabLabels[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.white : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Content ────────────────────────────────────────────────
  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _viewModel.error!,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _viewModel.loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (_viewModel.isEmpty) {
      return _buildEmptyState();
    }

    final items = _viewModel.notifications;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _viewModel.loadNotifications(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: items.length + (_viewModel.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          return _buildNotificationCard(items[index]);
        },
      ),
    );
  }

  // ── Notification card ──────────────────────────────────────
  Widget _buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        _viewModel.markAsRead(notification.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                _NotificationDetailView(notification: notification),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead
              ? null
              : Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadingIcon(notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.greyPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(NotificationModel notification) {
    if (notification.isSystemType && notification.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          notification.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _iconContainer(Icons.campaign, AppColors.primary),
        ),
      );
    }
    if (notification.type == 'payment_status') {
      return _iconContainer(Icons.payment, Colors.orange);
    }
    if (notification.type == 'order_status') {
      return _iconContainer(Icons.local_shipping_outlined, Colors.blue);
    }
    return _iconContainer(Icons.campaign, AppColors.primary);
  }

  Widget _iconContainer(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormatter.formatDateTime(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none,
            size: 70,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hiện tại không có thông báo nào.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Detail View ──────────────────────────────────────────────
class _NotificationDetailView extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationDetailView({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: notification.isSystemType
                  ? _buildSystemDetail()
                  : _buildOrderDetail(),
            ),
          ),
        ],
      ),
    );
  }

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
              'Chi tiết thông báo',
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

  // ── System: ảnh trên → tiêu đề → nội dung ─────────────────
  Widget _buildSystemDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notification.imageUrl != null)
          Image.network(
            notification.imageUrl!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormatter.formatDateTime(notification.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                notification.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Order: icon + tiêu đề → nội dung → mã đơn ────────────
  Widget _buildOrderDetail() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.type == 'payment_status'
                      ? Icons.payment
                      : Icons.local_shipping_outlined,
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            DateFormatter.formatDateTime(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
            child: Text(
              notification.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black,
                height: 1.6,
              ),
            ),
          ),
          if (notification.data?.orderNumber != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 18, color: AppColors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Mã đơn hàng: ',
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                  Text(
                    notification.data!.orderNumber!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
