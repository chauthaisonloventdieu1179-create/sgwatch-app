import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sgwatch_app/app/app.dart';
import 'package:sgwatch_app/core/services/firebase_notification_service.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseNotificationService.init();
  await LocalStorage.init();
  await FavoriteViewModel().load();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SGWatchApp());
}

class SGWatchApp extends StatelessWidget {
  const SGWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SGWatch',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_KeyboardDismissObserver()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
      home: const SplashScreen(),
    );
  }
}

/// Dismiss keyboard khi navigate sang page khác hoặc back về
class _KeyboardDismissObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
