import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/address/presentation/address_viewmodel.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sgwatch_app/features/profile/data/models/user_model.dart';
import 'package:sgwatch_app/core/services/firebase_notification_service.dart';
import 'package:sgwatch_app/app/config/constants.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRemoteDatasource _datasource;

  /// In-memory cache — survives navigation, cleared on kill app.
  static UserModel? _cachedUser;
  static int? _cachedPoint;
  static bool get hasCachedUser => _cachedUser != null;

  /// Called from SplashScreen to pre-fetch user info (requires token).
  static Future<void> prefetchUserInfo() async {
    try {
      final datasource = ProfileRemoteDatasource(ApiClient());
      _cachedUser = await datasource.getUserInfo();
      // Also save to local storage for offline fallback
      await LocalStorage.saveUser(_cachedUser!.toJson());
    } catch (_) {
      // Fallback: try local storage
      final local = await LocalStorage.getUser();
      if (local != null) {
        _cachedUser = UserModel.fromJson(local);
      }
    }
  }

  /// Clear in-memory cache (called on logout).
  static void clearCache() {
    _cachedUser = null;
    _cachedPoint = null;
  }

  ProfileViewModel()
      : _datasource = ProfileRemoteDatasource(ApiClient());

  UserModel? _user;
  int _point = 0;
  bool _isLoading = false;
  String? _error;
  bool _notificationEnabled = true;

  UserModel? get user => _user;
  int get point => _point;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get notificationEnabled => _notificationEnabled;

  String get userName => _user?.fullName ?? '';
  String? get avatarUrl => _user?.avatarUrl;

  Future<void> loadUserData() async {
    // Use cache if available — instant load
    if (_cachedUser != null) {
      _user = _cachedUser;
      _notificationEnabled = _user!.pushNotificationEnabled;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _datasource.getUserInfo();
      _cachedUser = _user;
      _notificationEnabled = _user!.pushNotificationEnabled;
      await LocalStorage.saveUser(_user!.toJson());
    } catch (e) {
      // Fallback: try local storage
      final local = await LocalStorage.getUser();
      if (local != null) {
        _user = UserModel.fromJson(local);
        _cachedUser = _user;
      } else {
        _error = _extractError(e, 'Không thể tải thông tin người dùng.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPoint() async {
    // Show cached value instantly while fetching fresh data
    if (_cachedPoint != null) {
      _point = _cachedPoint!;
      notifyListeners();
    }

    try {
      _point = await _datasource.getUserPoint();
      _cachedPoint = _point;
      notifyListeners();
    } catch (_) {
      // Keep cached or default 0
    }
  }

  Future<bool> toggleNotification(bool value) async {
    // Optimistic UI update
    _notificationEnabled = value;
    notifyListeners();

    try {
      final result = await _datasource.toggleNotification();
      _notificationEnabled = result;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert on failure
      _notificationEnabled = !value;
      _error = _extractError(e, 'Không thể thay đổi cài đặt thông báo.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? birthday,
    File? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _datasource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        birthday: birthday,
        avatar: avatar,
      );
      _cachedUser = _user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Không thể cập nhật thông tin.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await ApiClient().delete(Endpoints.withdraw);
    } catch (_) {}

    clearCache();
    AddressViewModel.clearCache();
    CartViewModel().clearCache();
    await LocalStorage.removeToken();
    await LocalStorage.removeUser();
    return true;
  }

  Future<bool> logout() async {
    // Gửi GET /logout?fcm_token=xx trước khi xóa token
    try {
      final fcmToken = await FirebaseNotificationService.getToken();
      final queryParams = <String, dynamic>{};
      if (fcmToken != null) queryParams['fcm_token'] = fcmToken;
      await ApiClient().get(Endpoints.logout, queryParameters: queryParams);
    } catch (_) {}

    clearCache();
    AddressViewModel.clearCache();
    CartViewModel().clearCache();
    await LocalStorage.removeToken();
    await LocalStorage.removeUser();
    return true;
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
