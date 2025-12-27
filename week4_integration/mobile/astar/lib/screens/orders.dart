import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/orders.dart';
import '../widgets/header.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  bool _isSearchFocused = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
      final orders = await _apiService.fetchOrders();
      if (!mounted) return;
      setState(() {
        _allOrders = orders;
        _filterOrders(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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

  void _filterOrders(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = List.from(_allOrders);
      } else {
        _filteredOrders = _allOrders
            .where(
              (o) =>
                  o.id.toString().contains(query) ||
                  o.productName.toLowerCase().contains(query.toLowerCase()) ||
                  o.customerName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    HapticFeedback.mediumImpact();
    try {
      await _apiService.updateOrderStatus(id, newStatus);
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

  void _showStatusPicker(Order order) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> statuses = ['pending', 'process', 'done', 'canceled'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1C26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "UPDATE STATUS",
              style: TextStyle(
                fontFamily: 'Monocraft',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF5B6EE1),
              ),
            ),
            const SizedBox(height: 12),
            ...statuses.map(
              (status) => ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(order.id, status);
                },
                title: Text(
                  status.toUpperCase(),
                  style: const TextStyle(fontFamily: 'Monocraft', fontSize: 13),
                ),
                trailing: order.status.toLowerCase() == status
                    ? const Icon(Icons.check_circle, color: Color(0xFF5B6EE1))
                    : null,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.greenAccent;
      case 'process':
        return const Color(0xFF8B9BFF);
      case 'pending':
        return Colors.orangeAccent;
      case 'canceled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? const Color(0xFF0F111A) : Colors.white;
    final Color surfaceColor = isDarkMode
        ? Colors.white.withAlpha(15)
        : const Color(0xFFEEF2F6);
    super.build(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgColor,
        body: RefreshIndicator(
          color: const Color(0xFF5B6EE1),
          onRefresh: _loadData,
          child: Column(
            children: [
              Header(title: 'Orders', dark: isDarkMode),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: _isSearchFocused
                        ? (isDarkMode
                              ? Colors.white.withAlpha(30)
                              : Colors.white)
                        : surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isSearchFocused
                          ? const Color(0xFF5B6EE1)
                          : Colors.white.withAlpha(isDarkMode ? 20 : 0),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _filterOrders,
                    cursorColor: const Color(0xFF5B6EE1),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Monocraft',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Order, Product, or User',
                      hintStyle: TextStyle(
                        fontFamily: 'Monocraft',
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.white38
                            : const Color(0xFF9D9D9D),
                      ),
                      prefixIcon: Icon(
                        Icons.receipt_long_rounded,
                        color: _isSearchFocused
                            ? const Color(0xFF5B6EE1)
                            : (isDarkMode ? Colors.white38 : Colors.grey),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterOrders('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading && _filteredOrders.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5B6EE1),
                        ),
                      )
                    : _filteredOrders.isEmpty
                    ? Center(
                        child: Text(
                          "No orders found",
                          style: TextStyle(
                            fontFamily: 'Monocraft',
                            color: isDarkMode
                                ? Colors.white24
                                : const Color(0xFF9D9D9D),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        controller: _scrollController,
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) =>
                            _buildOrderCard(_filteredOrders[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showStatusPicker(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withAlpha(12)
              : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white.withAlpha(20) : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: order.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.white.withAlpha(10)),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ORDER #${order.id}",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Monocraft',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: 9,
                              fontFamily: 'Monocraft',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontFamily: 'Monocraft',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order.customerName} • ${order.phoneNumber}",
                      style: TextStyle(
                        color: const Color(0xFF5B6EE1).withAlpha(180),
                        fontSize: 10,
                        fontFamily: 'Monocraft',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order.quantity} Items • ${DateFormat('dd MMM yyyy').format(order.orderDate)}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontFamily: 'Monocraft',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRupiah(order.totalAmount),
                      style: TextStyle(
                        color: isDarkMode
                            ? const Color(0xFF8B9BFF)
                            : const Color(0xFF5B6EE1),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Monocraft',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
