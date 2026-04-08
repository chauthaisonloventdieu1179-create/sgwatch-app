import 'package:sgwatch_app/app/config/constants.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  /// POST /login -> returns token
  Future<String> login(String email, String password) async {
    final response = await _apiClient.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data['token'] as String;
  }

  /// POST /register
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? inviteCode,
  }) async {
    final data = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    if (inviteCode != null && inviteCode.isNotEmpty) {
      data['invite_code'] = inviteCode;
    }
    final response = await _apiClient.post(Endpoints.register, data: data);
    return response.data['message']?.toString() ?? 'Đăng ký thành công';
  }

  /// POST /verify-registration
  Future<String> verifyRegistration(String email, String code) async {
    final response = await _apiClient.post(
      Endpoints.verifyRegistration,
      data: {'email': email, 'code': code},
    );
    return response.data['message']?.toString() ?? 'Xác thực thành công';
  }

  /// GET /user-info -> returns UserModel
  Future<UserModel> getUserInfo() async {
    final response = await _apiClient.get(Endpoints.userInfo);
    final userData = response.data['data']['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }
}
