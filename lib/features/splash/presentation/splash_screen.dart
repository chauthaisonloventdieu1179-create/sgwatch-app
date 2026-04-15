import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/core/widgets/main_scaffold.dart';
import 'package:sgwatch_app/core/services/chat_unread_service.dart';
import 'package:sgwatch_app/core/services/notification_unread_service.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';

import 'package:sgwatch_app/features/home/presentation/home_viewmodel.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_viewmodel.dart';
import 'package:sgwatch_app/core/services/firebase_notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Pre-fetch public data + user info (if logged in) + minimum 2s splash
    final futures = <Future>[
      HomeViewModel.prefetchHomeData(),
      Future.delayed(const Duration(seconds: 2)),
    ];

    // If user has token, also prefetch user info + cart
    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      futures.add(ProfileViewModel.prefetchUserInfo());
      futures.add(CartViewModel.prefetchCart());
      futures.add(ChatUnreadService.prefetchUnreadCount());
      futures.add(NotificationUnreadService.prefetchUnreadCount());
      futures.add(FirebaseNotificationService.registerToken());
    }

    await Future.wait(futures);

    // Xử lý notification từ terminated state (sau khi role đã được load)
    FirebaseNotificationService.processPendingNotification();

    if (!mounted) return;

    // Precache banner images so they display instantly on home
    await _precacheBanners();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  /// Download & cache banner images to disk (skip videos — they stream on demand).
  Future<void> _precacheBanners() async {
    final banners = HomeViewModel.cachedBanners;
    if (banners.isEmpty) return;

    final imageBanners = banners.where((b) => !b.isVideo).toList();
    await Future.wait(
      imageBanners.map((b) => precacheImage(
        CachedNetworkImageProvider(b.imageUrl),
        context,
      )),
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Image.asset(
              'assets/logo/logo_splash.png',
              width: 270,
              fit: BoxFit.contain,
            ),
            const Spacer(flex: 2),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
