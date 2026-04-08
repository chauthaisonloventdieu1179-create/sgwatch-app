import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/auth/presentation/login_screen.dart';

class AuthGuard {
  /// Check if user has token. If not, navigate to LoginScreen.
  /// Returns true if authenticated, false if redirected to login.
  static Future<bool> check(BuildContext context) async {
    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) return true;

    if (!context.mounted) return false;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return false;
  }
}
