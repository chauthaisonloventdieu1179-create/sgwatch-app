import 'package:flutter/material.dart';
import 'package:sgwatch_app/features/store_info/data/models/store_info_model.dart';

class StoreInfoViewModel extends ChangeNotifier {
  StoreInfoModel? _storeInfo;
  bool _isLoading = false;
  String? _error;

  StoreInfoModel? get storeInfo => _storeInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStoreInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(milliseconds: 300));
      _storeInfo = _getMockStoreInfo();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  StoreInfoModel _getMockStoreInfo() {
    return const StoreInfoModel(
      name: '大塚店（東京）',
      infoItems: [
        StoreInfoItem(
          icon: Icons.calendar_today_outlined,
          text: 'Tất cả các ngày trong tuần',
        ),
        StoreInfoItem(
          icon: Icons.access_time_outlined,
          text: '10：00〜19：00',
        ),
        StoreInfoItem(
          icon: Icons.directions_walk_outlined,
          text: 'Cách ga 5 phút đi bộ',
        ),
        StoreInfoItem(
          icon: Icons.location_on_outlined,
          text: '170-0005 東京都豊島区南大塚3-30-3\n'
              '大塚トーセイビルIII（旧：南大塚アロービル）7F\n'
              '(Bấm gọi 701 nếu quý khách đến vào CN)',
        ),
        StoreInfoItem(
          icon: Icons.phone_outlined,
          text: '00-0000-0000',
        ),
        StoreInfoItem(
          icon: Icons.email_outlined,
          text: 'info@Gmail.com',
        ),
      ],
    );
  }
}
