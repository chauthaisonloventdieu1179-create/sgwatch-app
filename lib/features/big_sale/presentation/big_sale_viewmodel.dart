import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/big_sale/data/datasources/big_sale_remote_datasource.dart';
import 'package:sgwatch_app/features/big_sale/data/models/big_sale_model.dart';

class BigSaleViewModel extends ChangeNotifier {
  final _datasource = BigSaleRemoteDatasource(ApiClient());

  bool _isLoading = false;
  String? _error;
  BigSaleModel? _bigSale;

  bool get isLoading => _isLoading;
  String? get error => _error;
  BigSaleModel? get bigSale => _bigSale;

  Future<void> loadBigSale(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bigSale = await _datasource.getBigSale(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải chương trình khuyến mãi.';
      notifyListeners();
    }
  }
}
