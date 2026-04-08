import 'package:sgwatch_app/core/storage/local_storage.dart';
import 'package:sgwatch_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sgwatch_app/features/auth/data/models/user_model.dart';

class AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepository(this._remoteDatasource);

  /// Login, save token, fetch & save user info
  Future<UserModel> login(String email, String password) async {
    final token = await _remoteDatasource.login(email, password);
    await LocalStorage.saveToken(token);

    final user = await _remoteDatasource.getUserInfo();
    await LocalStorage.saveUser(user.toJson());
    return user;
  }

  /// Register new account
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? inviteCode,
  }) async {
    return _remoteDatasource.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      inviteCode: inviteCode,
    );
  }

  /// Verify registration OTP
  Future<String> verifyRegistration(String email, String code) async {
    return _remoteDatasource.verifyRegistration(email, code);
  }

  /// Check if user has a saved token
  Future<bool> hasToken() async {
    final token = await LocalStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Fetch user info (used from splash when token exists)
  Future<UserModel> fetchAndSaveUserInfo() async {
    final user = await _remoteDatasource.getUserInfo();
    await LocalStorage.saveUser(user.toJson());
    return user;
  }

  /// Logout - clear local data
  Future<void> logout() async {
    await LocalStorage.removeToken();
    await LocalStorage.removeUser();
  }
}
