import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreInfoScreen extends StatelessWidget {
  const StoreInfoScreen({super.key});

  // ── Store data ────────────────────────────────────────────
  static const _stores = [
    _StoreData(
      name: 'NAMBA, OSAKA',
      schedule: 'Từ thứ 3 - Chủ Nhật (Nghỉ cố định thứ 2)',
      hours: '11:00 - 22:00',
      walkInfo: 'Cách ga 3 phút đi bộ',
      address: '〒542-0072 大阪市中央区高津2-8-6\nBunraku Daiei Building 3F',
      phone: '090-3978-1993',
      email: 'Sggtrantoan@gmail.com',
      mapQuery: '大阪市中央区高津2-8-6 Bunraku Daiei Building',
      mapImage: 'assets/images/image-map-jp.jpg',
    ),
    _StoreData(
      name: 'CHI NHÁNH TRUNG TÂM BẢO DƯỠNG\nĐỒNG HỒ TẠI HỒ CHÍ MINH, VIỆT NAM',
      schedule: 'Từ thứ 3 - Chủ Nhật (Nghỉ cố định thứ 2)',
      hours: '11:00 - 20:00',
      walkInfo: null,
      address: '1415 Phan Văn Trị, Gò Vấp, Hồ Chí Minh',
      phone: null,
      email: 'Sggtrantoan@gmail.com',
      mapQuery: '1415 Phan Văn Trị, Gò Vấp, Hồ Chí Minh',
      mapImage: 'assets/images/image-map-vn.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: const Color(0x0D000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin cửa hàng',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < _stores.length; i++) ...[
              _StoreCard(store: _stores[i]),
              if (i < _stores.length - 1) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Chi nhánh khác',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Store card ──────────────────────────────────────────────
class _StoreCard extends StatelessWidget {
  final _StoreData store;
  const _StoreCard({required this.store});

  void _openGoogleMaps() {
    final url = Uri.encodeFull(
      'https://www.google.com/maps/search/?api=1&query=${store.mapQuery}',
    );
    _launchUrl(url);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDF3526), Color(0xFFB72A1E)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.store, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    store.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info rows
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: store.schedule,
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text: store.hours,
                ),
                if (store.walkInfo != null) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.directions_walk_outlined,
                    text: store.walkInfo!,
                  ),
                ],
                const SizedBox(height: 14),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: store.address,
                ),
                if (store.phone != null) ...[
                  const SizedBox(height: 14),
                  _InfoRowTappable(
                    icon: Icons.phone_outlined,
                    text: store.phone!,
                    onTap: () => _launchUrl('tel:${store.phone}'),
                  ),
                ],
                const SizedBox(height: 14),
                _InfoRowTappable(
                  icon: Icons.email_outlined,
                  text: store.email,
                  onTap: () => _launchUrl('mailto:${store.email}'),
                ),
              ],
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AppColors.greyLight),
          ),

          // "Chỉ đường" button
          InkWell(
            onTap: _openGoogleMaps,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions,
                      size: 18,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Chỉ đường',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
          ),

          // Map image — tap to open Google Maps
          GestureDetector(
            onTap: _openGoogleMaps,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    store.mapImage,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                  // "Mở Google Maps" button overlay
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Mở Google Maps',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
        ],
      ),
    );
  }
}
// ── Store data model ──────────────────────────────────────────
class _StoreData {
  final String name;
  final String schedule;
  final String hours;
  final String? walkInfo;
  final String address;
  final String? phone;
  final String email;
  final String mapQuery;
  final String mapImage;

  const _StoreData({
    required this.name,
    required this.schedule,
    required this.hours,
    this.walkInfo,
    required this.address,
    this.phone,
    required this.email,
    required this.mapQuery,
    required this.mapImage,
  });
}

// ── Info row widgets ──────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRowTappable extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _InfoRowTappable({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1976D2),
                height: 1.5,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}