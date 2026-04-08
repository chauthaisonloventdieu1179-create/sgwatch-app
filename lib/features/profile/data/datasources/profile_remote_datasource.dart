import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/profile/data/models/user_model.dart';

class ProfileRemoteDatasource {
  final ApiClient _apiClient;

  ProfileRemoteDatasource(this._apiClient);

  /// GET /user-info
  Future<UserModel> getUserInfo() async {
    final response = await _apiClient.get(Endpoints.userInfo);
    final data = response.data['data']['user'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// GET /user-point
  Future<int> getUserPoint() async {
    final response = await _apiClient.get(Endpoints.userPoint);
    return response.data['data']['point'] as int? ?? 0;
  }

  /// POST /toggle-notification
  Future<bool> toggleNotification() async {
    final response = await _apiClient.post(Endpoints.toggleNotification);
    final user = response.data['data']['user'] as Map<String, dynamic>;
    return user['push_notification_enabled'] as bool? ?? true;
  }

  /// POST /update-profile (multipart/form-data)
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? birthday,
    File? avatar,
  }) async {
    final map = <String, dynamic>{};

    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (gender != null) map['gender'] = gender;
    if (birthday != null) map['birthday'] = birthday;

    if (avatar != null) {
      map['avatar'] = await MultipartFile.fromFile(
        avatar.path,
        filename: avatar.path.split('/').last,
      );
    }

    final formData = FormData.fromMap(map);
    final response = await _apiClient.post(
      Endpoints.updateProfile,
      data: formData,
    );
    final data = response.data['data']['user'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
