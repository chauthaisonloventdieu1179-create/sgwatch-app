import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/widgets/app_text_field.dart';
import 'package:sgwatch_app/features/auth/presentation/auth_viewmodel.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String passwordConfirmation;
  final AuthViewModel viewModel;

  const RegisterOtpScreen({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.passwordConfirmation,
    required this.viewModel,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _otpController = TextEditingController();
  late Timer _timer;
  int _countdown = 200;

  AuthViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _startCountdown();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _startCountdown() {
    _countdown = 200;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _viewModel.removeListener(_onChanged);
    _otpController.dispose();
    super.dispose();
  }

  bool get _isExpired => _countdown <= 0;

  Future<void> _handleVerify() async {
    if (_isExpired) {
      _showError('Mã OTP đã hết hạn. Vui lòng gửi lại.');
      return;
    }

    final code = _otpController.text.trim();
    if (code.isEmpty) {
      _showError('Vui lòng nhập mã OTP');
      return;
    }

    final success = await _viewModel.verifyRegistration(widget.email, code);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác thực thành công. Vui lòng đăng nhập.'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop back to login screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      _showError(_viewModel.error ?? 'Xác thực thất bại');
    }
  }

  Future<void> _handleResend() async {
    if (_countdown > 0) return;

    // Re-register to resend OTP
    final success = await _viewModel.register(
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      password: widget.password,
      passwordConfirmation: widget.passwordConfirmation,
    );

    if (!mounted) return;

    if (success) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại mã OTP')),
      );
    } else {
      _showError(_viewModel.error ?? 'Gửi lại thất bại');
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Nhập mã xác nhận',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mã được gửi tới email',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'OTP',
              hintText: 'Nhập mã OTP',
              controller: _otpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
                children: [
                  const TextSpan(
                    text: 'Lưu ý: Nếu không nhận được phản hồi, quý khách cần kiểm tra mục ',
                  ),
                  TextSpan(
                    text: 'Thư rác',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' trong tài khoản mail của mình!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không nhận được mã?',
              style: TextStyle(fontSize: 14, color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                GestureDetector(
                  onTap: _isExpired ? _handleResend : null,
                  child: Text(
                    'Gửi lại',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (!_isExpired)
                  Text(
                    ' trong $_countdown giây',
                    style: const TextStyle(fontSize: 14, color: AppColors.black),
                  ),
                if (_isExpired)
                  const Text(
                    ' - Mã đã hết hạn',
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
              ],
            ),
            const Spacer(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_viewModel.isLoading || _isExpired) ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.greyLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Xác nhận'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
