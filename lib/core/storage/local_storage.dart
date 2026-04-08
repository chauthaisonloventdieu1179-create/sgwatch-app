import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sgwatch_app/app/config/constants.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.tokenKey);
  }

  // User data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setString(AppConstants.userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = _prefs?.getString(AppConstants.userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> removeUser() async {
    await _prefs?.remove(AppConstants.userKey);
  }

  // Clear all
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
