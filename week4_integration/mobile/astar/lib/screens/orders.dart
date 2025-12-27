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

  String _sanitize(String e) {
    final l = e.toLowerCase();
    if (l.contains("http") || l.contains("vercel") || l.contains("socket")) {
      return "CONNECTION ERROR";
    }
    if (l.contains("foreign key")) return "USER ID NOT FOUND";
    if (l.contains("uuid")) return "INVALID UUID FORMAT";
    return e.replaceAll("Exception:", "").trim();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final pData = await _apiService.fetchProducts();
      if (mounted) setState(() => _allProducts = pData);

      final oData = await _apiService.fetchOrders();
      if (mounted) {
        setState(() {
          _allOrders = oData;
          _displayOrders = _allOrders
              .where((o) => o.status == 'pending' || o.status == 'process')
              .toList();
          _doneCount = _allOrders.where((o) => o.status == 'done').length;
          _canceledCount = _allOrders
              .where((o) => o.status == 'canceled')
              .length;
        });
      }
    } catch (e) {
      debugPrint("ERR: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OrderFormOverlay(
        products: _allProducts,
        dark: Theme.of(context).brightness == Brightness.dark,
        onSave: (Map<String, dynamic> d) async {
          Navigator.pop(modalContext); // Tutup modal dulu
          try {
            await _apiService.createOrder(d);
            _loadData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "ORDER CREATED",
                    style: TextStyle(fontFamily: 'Monocraft'),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _sanitize(e.toString()).toUpperCase(),
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

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    super.build(context);
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0F111A) : Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B6EE1),
        onPressed: _openForm,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            Header(title: 'Orders', dark: dark),
            _buildSummary(dark),
            Expanded(
              child: _isLoading && _displayOrders.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5B6EE1),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _displayOrders.length,
                      itemBuilder: (context, i) =>
                          _card(_displayOrders[i], dark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(bool d) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _badge("DONE", _doneCount, Colors.greenAccent, d),
          const SizedBox(width: 10),
          _badge("CANCELED", _canceledCount, Colors.redAccent, d),
        ],
      ),
    );
  }

  Widget _badge(String l, int c, Color clr, bool d) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: d ? Colors.white.withAlpha(10) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l,
              style: const TextStyle(
                fontFamily: 'Monocraft',
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
            Text(
              c.toString(),
              style: TextStyle(
                fontFamily: 'Monocraft',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: clr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Order o, bool d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: d ? Colors.white.withAlpha(12) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: o.imageUrl,
              width: 65,
              height: 65,
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
                  "ORDER #${o.id}",
                  style: TextStyle(
                    color: d ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    fontFamily: 'Monocraft',
                  ),
                ),
                Text(
                  o.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: d ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                    fontFamily: 'Monocraft',
                  ),
                ),
                Text(
                  "${o.customerName} • ${o.quantity} pcs",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                    fontFamily: 'Monocraft',
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(o.totalAmount),
                  style: TextStyle(
                    color: d
                        ? const Color(0xFF8B9BFF)
                        : const Color(0xFF5B6EE1),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    fontFamily: 'Monocraft',
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  String n = o.status == 'pending'
                      ? 'process'
                      : (o.status == 'process' ? 'done' : '');
                  if (n.isNotEmpty) {
                    _apiService
                        .updateOrderStatus(o.id, n)
                        .then((_) => _loadData());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (o.status == 'pending'
                                ? Colors.orangeAccent
                                : const Color(0xFF5B6EE1))
                            .withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    o.status == 'pending' ? "PROCESS" : "FINISH",
                    style: TextStyle(
                      color: o.status == 'pending'
                          ? Colors.orangeAccent
                          : const Color(0xFF8B9BFF),
                      fontSize: 8,
                      fontFamily: 'Monocraft',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _apiService
                    .updateOrderStatus(o.id, 'canceled')
                    .then((_) => _loadData()),
                child: Icon(
                  Icons.cancel_outlined,
                  color: Colors.redAccent.withAlpha(100),
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
