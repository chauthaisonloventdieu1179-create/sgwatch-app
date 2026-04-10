import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/support/presentation/support_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final SupportViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SupportViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadSupportData();
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

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showZaloQr() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/logo/zalo-logo.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vui lòng kết bạn để trao đổi\ntrực tiếp với chúng tôi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/qr-zalo.jpg',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSocialTap(String title) {
    if (title == 'Zalo') {
      _showZaloQr();
      return;
    }
    final link = _viewModel.socialLink(title);
    if (link != null) _openLink(link);
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
          'Hỗ trợ',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildContactCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Kết nối với chúng tôi'),
            const SizedBox(height: 8),
            _buildSocialCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liên hệ',
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _viewModel.phoneNumber,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.phone, color: AppColors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildSocialCard() {
    final items = _viewModel.socialItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
          children: items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return _buildSocialItem(entry.value, isLast);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSocialItem(String title, bool isLast) {
    return Column(
      children: [
        InkWell(
          onTap: () => _onSocialTap(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                _buildSocialIcon(title),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                ),
                Icon(
                  title == 'Zalo' ? Icons.qr_code : Icons.open_in_new,
                  color: AppColors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: AppColors.greyLight,
          ),
      ],
    );
  }

  Widget _buildSocialIcon(String title) {
    const logoMap = {
      'Facebook': 'assets/logo/logo-facebook.webp',
      'Zalo': 'assets/logo/zalo-logo.png',
      'TikTok': 'assets/logo/logo-tiktok.webp',
    };

    final logoPath = logoMap[title];
    if (logoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(logoPath, width: 30, height: 30, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.greyPlaceholder,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
