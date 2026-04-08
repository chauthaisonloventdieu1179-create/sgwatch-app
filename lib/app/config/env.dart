class Env {
  Env._();

  /// Base URL
  static const String baseURL = 'http://api.sgwatch.jp/';

  /// API Path prefix
  static const String apiPath = '/api/v1';

  /// Full API URL
  static String get apiURL => baseURL + apiPath;

  /// Request timeout (seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
}

class PusherConfig {
  PusherConfig._();

  static const String appId = '2120644';
  static const String apiKey = 'c84c834e526013c43c55';
  static const String secret = '5ba2bbf27f60f7a3ca73';
  static const String cluster = 'ap3';
  static const bool useTLS = true;
}
