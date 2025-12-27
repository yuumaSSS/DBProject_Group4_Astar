import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/orders.dart';
import '../models/products.dart';
import '../widgets/header.dart';
import '../widgets/order_form_overlay.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  List<Order> _allOrders = [];
  List<Product> _allProducts = [];
  List<Order> _displayOrders = [];
  int _doneCount = 0;
  int _canceledCount = 0;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _sanitizeError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains("http") ||
        lower.contains("vercel") ||
        lower.contains("supabase") ||
        lower.contains("socket")) {
      return "NETWORK ERROR: DATABASE CONNECTION FAILED";
    }
    return error;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.fetchOrders(),
        _apiService.fetchProducts(),
      ]);

      if (!mounted) return;
      setState(() {
        _allOrders = results[0] as List<Order>;
        _allProducts = results[1] as List<Product>;
        _displayOrders = _allOrders
            .where((o) => o.status == 'pending' || o.status == 'process')
            .toList();
        _doneCount = _allOrders.where((o) => o.status == 'done').length;
        _canceledCount = _allOrders.where((o) => o.status == 'canceled').length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!e.toString().contains("null")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _sanitizeError(e.toString()).toUpperCase(),
              style: const TextStyle(fontFamily: 'Monocraft'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleStatusCycle(Order order) async {
    HapticFeedback.mediumImpact();
    String nextStatus = '';
    if (order.status == 'pending')
      nextStatus = 'process';
    else if (order.status == 'process')
      nextStatus = 'done';

    if (nextStatus.isNotEmpty) {
      try {
        await _apiService.updateOrderStatus(order.id, nextStatus);
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _sanitizeError(e.toString()).toUpperCase(),
                style: const TextStyle(fontFamily: 'Monocraft'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _openManualOrderForm() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderFormOverlay(
        products: _allProducts,
        dark: isDark,
        onSave: (data) async {
          Navigator.pop(context);
          try {
            await _apiService.createOrder(data);
            _loadData();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _sanitizeError(e.toString()).toUpperCase(),
                    style: const TextStyle(fontFamily: 'Monocraft'),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  String formatRupiah(double price) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(price);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F111A) : Colors.white;
    super.build(context);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B6EE1),
        onPressed: _openManualOrderForm,
        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF5B6EE1),
        onRefresh: _loadData,
        child: Column(
          children: [
            Header(title: 'Orders', dark: isDark),
            _buildSummaryBar(isDark),
            Expanded(
              child: _isLoading && _displayOrders.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5B6EE1),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _displayOrders.length,
                      itemBuilder: (context, index) =>
                          _buildActiveOrderCard(_displayOrders[index], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _summaryBadge("DONE", _doneCount, Colors.greenAccent, isDark),
          const SizedBox(width: 10),
          _summaryBadge("CANCELED", _canceledCount, Colors.redAccent, isDark),
        ],
      ),
    );
  }

  Widget _summaryBadge(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Monocraft',
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'Monocraft',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard(Order order, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(12) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: order.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorWidget: (c, u, e) => const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ORDER #${order.id}",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    fontFamily: 'Monocraft',
                  ),
                ),
                Text(
                  order.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    fontFamily: 'Monocraft',
                  ),
                ),
                Text(
                  "${order.customerName} • ${order.quantity} pcs",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'Monocraft',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatRupiah(order.totalAmount),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF8B9BFF)
                        : const Color(0xFF5B6EE1),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Monocraft',
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => _handleStatusCycle(order),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: order.status == 'pending'
                        ? Colors.orangeAccent.withAlpha(40)
                        : const Color(0xFF5B6EE1).withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.status == 'pending' ? "PROCESS" : "FINISH",
                    style: TextStyle(
                      color: order.status == 'pending'
                          ? Colors.orangeAccent
                          : const Color(0xFF8B9BFF),
                      fontSize: 9,
                      fontFamily: 'Monocraft',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _updateStatus(order.id, 'canceled'),
                child: Icon(
                  Icons.cancel_outlined,
                  color: Colors.redAccent.withAlpha(100),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    HapticFeedback.heavyImpact();
    try {
      await _apiService.updateOrderStatus(id, status);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _sanitizeError(e.toString()).toUpperCase(),
              style: const TextStyle(fontFamily: 'Monocraft'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
