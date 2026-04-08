import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/auth/data/datasources/password_remote_datasource.dart';

class PasswordViewModel extends ChangeNotifier {
  final PasswordRemoteDatasource _datasource;

  PasswordViewModel(this._datasource);

  bool _isLoading = false;
  String? _error;
  String? _resetToken;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get resetToken => _resetToken;

  /// Bước 1: Gửi OTP qua email
  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _datasource.sendOtp(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Gửi OTP thất bại. Vui lòng thử lại.');
      notifyListeners();
      return false;
    }
  }

  /// Bước 2: Verify OTP → nhận reset_token
  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resetToken = await _datasource.verifyOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Mã OTP không đúng. Vui lòng thử lại.');
      notifyListeners();
      return false;
    }
  }

  /// Bước 3: Reset password
  Future<bool> resetPassword(String password, String passwordConfirmation) async {
    if (_resetToken == null) {
      _error = 'Phiên đã hết hạn. Vui lòng thử lại từ đầu.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _datasource.resetPassword(
        resetToken: _resetToken!,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Đặt lại mật khẩu thất bại. Vui lòng thử lại.');
      notifyListeners();
      return false;
    }
  }

  String _extractError(Object e, String fallback) {
    if (e is DioException && e.response?.data is Map) {
      final data = e.response!.data as Map;
      final msg = data['message'] ?? data['data']?['message'];
      if (msg != null) return msg.toString();
    }
    return fallback;
  }
}
