import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/widgets/app_text_field.dart';
import 'package:sgwatch_app/features/auth/presentation/password_viewmodel.dart';
import 'package:sgwatch_app/features/auth/presentation/reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final PasswordViewModel viewModel;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.viewModel,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  late Timer _timer;
  int _countdown = 200;

  PasswordViewModel get _viewModel => widget.viewModel;

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

    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showError('Vui lòng nhập mã xác nhận');
      return;
    }

    final success = await _viewModel.verifyOtp(widget.email, otp);
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(viewModel: _viewModel),
        ),
      );
    } else {
      _showError(_viewModel.error ?? 'Xác nhận OTP thất bại');
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_isExpired) return;

    final success = await _viewModel.sendOtp(widget.email);
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
                  onTap: _isExpired ? _handleResendOtp : null,
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
