import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/core/utils/date_formatter.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_inventory_model.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _ds = AdminDatasource(ApiClient());

  // Tab 0: export (hàng đi), Tab 1: import (hàng nhập)
  final List<List<AdminInventoryModel>> _records = [[], []];
  final List<bool> _isLoading = [false, false];
  final List<int> _currentPage = [1, 1];
  final List<bool> _hasMore = [true, true];
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  static const _types = ['export', 'import'];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollControllers[0].addListener(() => _onScroll(0));
    _scrollControllers[1].addListener(() => _onScroll(1));
    _loadRecords(0);
    _loadRecords(1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onScroll(int tab) {
    final ctrl = _scrollControllers[tab];
    if (ctrl.position.pixels >= ctrl.position.maxScrollExtent - 150) {
      _loadMore(tab);
    }
  }

  String get _formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadRecords(int tab) async {
    if (_isLoading[tab]) return;
    setState(() {
      _isLoading[tab] = true;
      _records[tab].clear();
      _currentPage[tab] = 1;
      _hasMore[tab] = true;
    });
    try {
      final res = await _ds.getInventoryHistories(
        date: _formattedDate,
        type: _types[tab],
        page: 1,
      );
      setState(() {
        _records[tab] = res.records;
        _hasMore[tab] = res.currentPage < res.lastPage;
        _currentPage[tab] = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading[tab] = false);
    }
  }

  Future<void> _loadMore(int tab) async {
    if (_isLoading[tab] || !_hasMore[tab]) return;
    final nextPage = _currentPage[tab] + 1;
    setState(() => _isLoading[tab] = true);
    try {
      final res = await _ds.getInventoryHistories(
        date: _formattedDate,
        type: _types[tab],
        page: nextPage,
      );
      setState(() {
        _records[tab].addAll(res.records);
        _hasMore[tab] = res.currentPage < res.lastPage;
        _currentPage[tab] = res.currentPage;
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading[tab] = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadRecords(0);
      _loadRecords(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hàng tồn kho',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.white),
            onPressed: _pickDate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Hàng đi'),
            Tab(text: 'Hàng nhập'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date chip
          Container(
            color: AppColors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  'Ngày: $_formattedDate',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.black),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Đổi ngày',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [0, 1].map((tab) => _buildList(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(int tab) {
    if (_isLoading[tab] && _records[tab].isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_records[tab].isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Không có dữ liệu',
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadRecords(tab),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadRecords(tab),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollControllers[tab],
        padding: const EdgeInsets.all(16),
        itemCount: _records[tab].length + (_hasMore[tab] ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          if (index == _records[tab].length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return _buildRecordCard(_records[tab][index], tab);
        },
      ),
    );
  }

  Widget _buildRecordCard(AdminInventoryModel record, int tab) {
    final isExport = tab == 0;
    final color = isExport ? Colors.red : Colors.green;
    final icon = isExport ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: record.product.primaryImageUrl != null
                ? Image.network(
                    record.product.primaryImageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.product.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (record.product.sku.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('SKU: ${record.product.sku}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey)),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      DateFormatter.formatDateTime(record.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '${record.quantity}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.stockBefore} → ${record.stockAfter}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.grey),
                ),
                if (record.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.backgroundGrey,
      child: const Icon(Icons.image, color: AppColors.grey, size: 24),
    );
  }
}
