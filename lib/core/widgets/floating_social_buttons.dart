import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/services/chat_unread_service.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/chat/presentation/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FloatingSocialButtons extends StatefulWidget {
  const FloatingSocialButtons({super.key});

  @override
  State<FloatingSocialButtons> createState() => _FloatingSocialButtonsState();
}

class _FloatingSocialButtonsState extends State<FloatingSocialButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openTikTok() async {
    final uri = Uri.parse('https://www.tiktok.com/@sgwatch2021?_r=1&_t=ZS-95ng1UNcd76');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showZaloQr(BuildContext context) {
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
              // Zalo icon
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
              // QR image
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

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // TikTok
          _buildImageButton(
            onTap: _openTikTok,
            assetPath: 'assets/logo/logotiktok.png',
          ),
          const SizedBox(height: 10),
          // Zalo
          _buildImageButton(
            onTap: () => _showZaloQr(context),
            assetPath: 'assets/logo/zalo-logo.png',
          ),
          const SizedBox(height: 10),
          // Chat CSKH với animation nhấp nháy
          ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _openChat(context),
              child: ValueListenableBuilder<int>(
                valueListenable: ChatUnreadService.instance.unreadCount,
                builder: (_, unread, __) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label "Tư vấn trực tiếp"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Tư vấn\ntrực tiếp',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // FAB icon button
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo/messenger-logo.png',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (unread > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Center(
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton({
    required VoidCallback onTap,
    required String assetPath,
    double size = 48,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(assetPath, width: size, height: size, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
