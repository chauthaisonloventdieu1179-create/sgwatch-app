import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/big_sale/data/datasources/big_sale_remote_datasource.dart';
import 'package:sgwatch_app/features/big_sale/data/models/big_sale_model.dart';

class BigSaleViewModel extends ChangeNotifier {
  final _datasource = BigSaleRemoteDatasource(ApiClient());

  bool _isLoading = false;
  String? _error;

  // List
  List<BigSaleModel> _bigSales = [];

  // Detail
  BigSaleModel? _bigSale;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BigSaleModel> get bigSales => _bigSales;
  BigSaleModel? get bigSale => _bigSale;

  /// GET /big-sales
  Future<void> loadBigSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bigSales = await _datasource.getBigSales();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải danh sách khuyến mãi.';
      notifyListeners();
    }
  }

  /// GET /big-sales/{id}
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
