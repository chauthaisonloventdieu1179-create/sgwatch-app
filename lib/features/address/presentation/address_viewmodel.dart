import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/address/data/datasources/address_remote_datasource.dart';
import 'package:sgwatch_app/features/address/data/models/address_model.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRemoteDatasource _datasource;

  /// In-memory cache — survives navigation, cleared on kill app.
  static List<AddressModel>? _cachedAddresses;

  /// Clear in-memory cache (called on logout).
  static void clearCache() {
    _cachedAddresses = null;
  }

  AddressViewModel(this._datasource);

  bool _isLoading = false;
  String? _error;
  List<AddressModel> _addresses = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AddressModel> get addresses => _addresses;

  /// GET /prefectures
  Future<List<Map<String, dynamic>>> fetchPrefectures() async {
    try {
      return await _datasource.getPrefectures();
    } catch (e) {
      debugPrint('[Address] Fetch prefectures error: $e');
      return [];
    }
  }

  Future<void> loadAddresses() async {
    // Use cache if available — instant load
    if (_cachedAddresses != null) {
      _addresses = List.from(_cachedAddresses!);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _datasource.getAddresses();
      _cachedAddresses = List.from(_addresses);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Không thể tải danh sách địa chỉ.');
      notifyListeners();
    }
  }

  Future<bool> addAddress(AddressModel address, {File? imageFile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _datasource.createAddress(
        address,
        imageFile: imageFile,
      );
      _addresses.add(created);
      _cachedAddresses = List.from(_addresses);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Không thể thêm địa chỉ.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(
    int id,
    AddressModel address, {
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _datasource.updateAddress(
        id,
        address,
        imageFile: imageFile,
      );
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = updated;
      }
      _cachedAddresses = List.from(_addresses);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Không thể cập nhật địa chỉ.');
      notifyListeners();
      return false;
    }
  }

  /// GET /addresses/{id} — lấy chi tiết để mở màn edit
  Future<AddressModel?> getAddressDetail(int id) async {
    try {
      return await _datasource.getAddress(id);
    } catch (e) {
      _error = _extractError(e, 'Không thể tải chi tiết địa chỉ.');
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteAddress(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _datasource.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      _cachedAddresses = List.from(_addresses);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _extractError(e, 'Không thể xóa địa chỉ.');
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
