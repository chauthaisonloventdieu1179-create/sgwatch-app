import 'package:flutter/foundation.dart';

class SupportViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String get phoneNumber => '090 3978 1993';

  List<String> get socialItems => const [
        'Facebook',
        'Zalo',
        'TikTok',
      ];

  String? socialLink(String title) {
    switch (title) {
      case 'Facebook':
        return 'https://www.facebook.com/share/1B28CbZ8yg/?mibextid=wwXIfr';
      case 'TikTok':
        return 'https://www.tiktok.com/@sgwatch2021?_r=1&_t=ZS-95Pmu2Mvz3E';
      default:
        return null;
    }
  }

  Future<void> loadSupportData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
