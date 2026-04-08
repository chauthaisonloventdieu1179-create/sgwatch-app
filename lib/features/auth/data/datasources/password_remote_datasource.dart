import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';

class PasswordRemoteDatasource {
  final ApiClient _apiClient;

  PasswordRemoteDatasource(this._apiClient);

  /// POST /password/otp/send
  Future<void> sendOtp(String email) async {
    final data = {'email': email};
    debugPrint('[Password] ── sendOtp ──');
    debugPrint('[Password]   URL: ${Endpoints.sendOtp}');
    debugPrint('[Password]   REQUEST: $data');
    try {
      final response = await _apiClient.post(Endpoints.sendOtp, data: data);
      debugPrint('[Password]   STATUS: ${response.statusCode}');
      debugPrint('[Password]   RESPONSE: ${response.data}');
    } catch (e) {
      debugPrint('[Password]   ERROR: $e');
      rethrow;
    }
  }

  /// POST /password/otp/verify → returns reset_token
  Future<String> verifyOtp(String email, String otp) async {
    final data = {'email': email, 'otp': otp};
    debugPrint('[Password] ── verifyOtp ──');
    debugPrint('[Password]   URL: ${Endpoints.verifyOtp}');
    debugPrint('[Password]   REQUEST: $data');
    try {
      final response = await _apiClient.post(Endpoints.verifyOtp, data: data);
      debugPrint('[Password]   STATUS: ${response.statusCode}');
      debugPrint('[Password]   RESPONSE: ${response.data}');
      return response.data['reset_token'] as String;
    } catch (e) {
      debugPrint('[Password]   ERROR: $e');
      rethrow;
    }
  }

  /// POST /password/reset
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = {
      'reset_token': resetToken,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    debugPrint('[Password] ── resetPassword ──');
    debugPrint('[Password]   URL: ${Endpoints.resetPassword}');
    debugPrint('[Password]   REQUEST: $data');
    try {
      final response = await _apiClient.post(Endpoints.resetPassword, data: data);
      debugPrint('[Password]   STATUS: ${response.statusCode}');
      debugPrint('[Password]   RESPONSE: ${response.data}');
    } catch (e) {
      debugPrint('[Password]   ERROR: $e');
      rethrow;
    }
  }
}
