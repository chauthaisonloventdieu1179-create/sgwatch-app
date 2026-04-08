import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/widgets/app_button.dart';
import 'package:sgwatch_app/core/widgets/app_text_field.dart';
import 'package:sgwatch_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sgwatch_app/features/auth/data/repositories/auth_repository.dart';
import 'package:sgwatch_app/features/auth/presentation/auth_viewmodel.dart';
import 'package:sgwatch_app/features/auth/presentation/register_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final datasource = AuthRemoteDatasource(apiClient);
    final repository = AuthRepository(datasource);
    _viewModel = AuthViewModel(repository);
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final inviteCode = _referralCodeController.text.trim();

    if (email.isEmpty || lastName.isEmpty || firstName.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin.');
      return;
    }
    if (password.length < 8 || password.length > 16) {
      _showError('Mật khẩu phải từ 8 đến 16 ký tự.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Xác nhận mật khẩu không khớp.');
      return;
    }

    final success = await _viewModel.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
      inviteCode: inviteCode.isNotEmpty ? inviteCode : null,
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterOtpScreen(
            email: email,
            firstName: firstName,
            lastName: lastName,
            password: password,
            passwordConfirmation: confirmPassword,
            viewModel: _viewModel,
          ),
        ),
      );
    } else {
      _showError(_viewModel.error ?? 'Đăng ký thất bại');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng ký',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Họ',
              controller: _lastNameController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Tên đệm và tên',
              controller: _firstNameController,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            AppTextField(
              label: 'Xác nhận mật khẩu',
              obscureText: _obscureConfirmPassword,
              controller: _confirmPasswordController,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grey,
                ),
                onPressed: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
            // const SizedBox(height: 16),
            // AppTextField(
            //   label: 'Mã giới thiệu (nếu có)',
            //   controller: _referralCodeController,
            // ),
            const SizedBox(height: 24),
            _viewModel.isLoading
                ? const SizedBox(
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : AppButton(
                    text: 'Đăng ký',
                    onPressed: _handleRegister,
                  ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Đăng nhập'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
