import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:sgwatch_app/features/orders/data/models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  final _datasource = OrderRemoteDatasource(ApiClient());

  bool _isLoading = false;
  String? _error;
  int _selectedTab = 0;

  // Cache orders per tab index
  final Map<int, List<OrderListItem>> _ordersByTab = {};
  final Set<int> _loadedTabs = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedTab => _selectedTab;

  List<OrderListItem> get currentOrders => _ordersByTab[_selectedTab] ?? [];

  static const List<OrderStatus> _tabStatuses = [
    OrderStatus.pending,
    OrderStatus.shipping,
    OrderStatus.completed,
    OrderStatus.cancelled,
    OrderStatus.refunded,
  ];

  Future<void> loadInitialTab() async {
    await _loadTab(_selectedTab);
  }

  Future<void> selectTab(int index) async {
    _selectedTab = index;
    notifyListeners();
    if (!_loadedTabs.contains(index)) {
      await _loadTab(index);
    }
  }

  Future<void> refreshCurrentTab() async {
    _loadedTabs.remove(_selectedTab);
    await _loadTab(_selectedTab);
  }

  Future<void> _loadTab(int tabIndex) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final status = _tabStatuses[tabIndex].apiValue;
      final orders = await _datasource.getOrders(status);
      _ordersByTab[tabIndex] = orders;
      _loadedTabs.add(tabIndex);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải danh sách đơn hàng.';
      notifyListeners();
    }
  }

  Future<OrderDetailModel?> loadOrderDetail(int orderId) async {
    try {
      return await _datasource.getOrderDetail(orderId);
    } catch (_) {
      return null;
    }
  }
}
