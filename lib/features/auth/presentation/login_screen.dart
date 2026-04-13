import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/widgets/app_button.dart';
import 'package:sgwatch_app/core/widgets/app_text_field.dart';
import 'package:sgwatch_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sgwatch_app/features/auth/data/repositories/auth_repository.dart';
import 'package:sgwatch_app/features/auth/presentation/auth_viewmodel.dart';
import 'package:sgwatch_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:sgwatch_app/features/auth/presentation/register_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/home/presentation/home_viewmodel.dart';
import 'package:sgwatch_app/features/profile/presentation/profile_viewmodel.dart';
import 'package:sgwatch_app/core/services/firebase_notification_service.dart';
import 'package:sgwatch_app/core/services/notification_unread_service.dart';
import 'package:sgwatch_app/core/widgets/main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final datasource = AuthRemoteDatasource(apiClient);
    final repository = AuthRepository(datasource);
    _viewModel = AuthViewModel(repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    final success = await _viewModel.login(email, password);

    if (!mounted) return;

    if (success) {
      // Prefetch song song: home data, user info, cart
      await Future.wait([
        HomeViewModel.prefetchHomeData(),
        ProfileViewModel.prefetchUserInfo(),
        CartViewModel().loadCart(),
        FirebaseNotificationService.registerToken(),
        NotificationUnreadService.prefetchUnreadCount(),
      ]);

      if (!mounted) return;

      // Precache banners trước khi vào home
      final banners = HomeViewModel.cachedBanners;
      final imageBanners = banners.where((b) => !b.isVideo).toList();
      if (imageBanners.isNotEmpty) {
        await Future.wait(
          imageBanners.map((b) => precacheImage(NetworkImage(b.imageUrl), context)),
        ).timeout(const Duration(seconds: 2), onTimeout: () => []);
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'Đăng nhập thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              Center(
                child: Image.asset(
                  'assets/logo/logo_login.png',
                  width: 196,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              // Email
              AppTextField(
                label: 'Email',
                hintText: 'example@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password
              AppTextField(
                label: 'Mật khẩu',
                obscureText: _obscurePassword,
                controller: _passwordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Forgot password
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Quên mật khẩu'),
                ),
              ),
              const SizedBox(height: 16),
              // Login button
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return AppButton(
                    text: 'Đăng nhập',
                    onPressed: _handleLogin,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Register link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Tạo tài khoản'),
                ),
              ),
              const SizedBox(height: 8),
              // Browse without account
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScaffold()),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.grey,
                  ),
                  child: const Text('Xem mà không cần tài khoản'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
