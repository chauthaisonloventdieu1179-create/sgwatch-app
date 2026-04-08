import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/auth/data/models/user_model.dart';
import 'package:sgwatch_app/features/auth/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  /// Login with email & password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Đăng nhập thất bại. Vui lòng kiểm tra lại.');
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? inviteCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        inviteCode: inviteCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Đăng ký thất bại. Vui lòng thử lại.');
      notifyListeners();
      return false;
    }
  }

  /// Verify registration OTP
  Future<bool> verifyRegistration(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.verifyRegistration(email, code);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Xác thực thất bại. Vui lòng thử lại.');
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
