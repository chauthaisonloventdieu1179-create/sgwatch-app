import 'package:flutter/foundation.dart';

class SupportViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String get phoneNumber => '00-0000-0000';

  List<String> get policyItems => const [
        'Chi phí vận chuyển',
        'Chính sách hoàn tiền',
        'Chính sách bảo mật',
        'Chính sách bảo hành đồng hồ',
        'Chính sách bảo hành laptop',
        'Chính sách bảo hành sim',
      ];

  List<String> get socialItems => const [
        'Facebook',
        // 'Youtube',
        'Messenger',
        'Zalo',
        // 'Khiếu nại',
      ];

  Future<void> loadSupportData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void openPolicy(int index) {
    // TODO: Navigate to policy detail
  }

  void openSocialLink(int index) {
    // TODO: Open external link
  }
}
