import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/app/app.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/app/config/env.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/auth/presentation/login_screen.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  /// Endpoints không cần xử lý 401 (tự handle lỗi riêng)
  static const _skipAuthEndpoints = [
    Endpoints.login,
    Endpoints.register,
    Endpoints.sendOtp,
    Endpoints.verifyOtp,
    Endpoints.resetPassword,
  ];

  factory ApiClient() {
    return _instance ??= ApiClient._internal();
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiURL,
        connectTimeout: Duration(seconds: Env.connectTimeout),
        receiveTimeout: Duration(seconds: Env.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final shouldSkip = _skipAuthEndpoints.any(
              (ep) => path.endsWith(ep),
            );

            if (!shouldSkip) {
              await _handleUnauthorized();
              handler.reject(error);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 401 → xóa token + user → quay về Login
  Future<void> _handleUnauthorized() async {
    await LocalStorage.removeToken();
    await LocalStorage.removeUser();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
