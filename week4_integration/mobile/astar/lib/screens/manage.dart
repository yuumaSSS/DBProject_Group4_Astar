import 'dart:ui';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/products.dart';
import '../widgets/header.dart';
import '../widgets/product_form_overlay.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _fabTimer;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final Set<int> _selectedIds = {};
  bool _isInit = true;
  bool _isFabExtended = true;
  bool _isLoading = false;
  bool _isSearchFocused = false;
  bool _isSelectionMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _fabTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is List<Product>) {
        _allProducts = extra;
        _filteredProducts = List.from(_allProducts);
      } else {
        _loadData();
      }
      _isInit = false;
    }
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
      final products = await _apiService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _filterProducts(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleSelection(int id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  void _openFormOverlay([Product? product]) {
    if (_isSelectionMode) return;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFormOverlay(
        product: product,
        onSave: (data) async {
          Navigator.pop(context);
          try {
            if (product == null) {
              await _apiService.createProduct(data);
            } else {
              await _apiService.updateProduct(product.id, data);
            }
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
        dark: isDarkMode,
      ),
    );
  }

  void _showDeleteConfirm({int? singleId}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final int count = singleId != null ? 1 : _selectedIds.length;
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(180),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1A1C26) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDarkMode
                  ? Colors.white.withAlpha(20)
                  : const Color(0xFFEEF2F6),
            ),
          ),
          title: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 40,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "DELETE $count ITEM${count > 1 ? 'S' : ''}?",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "This action cannot be undone and items will be removed from database.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Monocraft',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color: Color(0xFF5B6EE1),
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  if (singleId != null) {
                    await _apiService.deleteProduct(singleId);
                  } else {
                    await _apiService.deleteMultipleProducts(
                      _selectedIds.toList(),
                    );
                  }
                  _exitSelection();
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
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              child: const Text(
                "DELETE",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? const Color(0xFF0F111A) : Colors.white;
    final Color surfaceColor = isDarkMode
        ? Colors.white.withAlpha(15)
        : const Color(0xFFEEF2F6);
    super.build(context);
    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) _exitSelection();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: bgColor,
          floatingActionButton: FloatingActionButton.extended(
            isExtended: _isFabExtended,
            backgroundColor: _isSelectionMode
                ? Colors.red
                : const Color(0xFF5B6EE1),
            onPressed: _isSelectionMode
                ? () => _showDeleteConfirm()
                : _openFormOverlay,
            icon: Icon(
              _isSelectionMode
                  ? Icons.delete_sweep_rounded
                  : Icons.add_box_rounded,
              color: Colors.white,
            ),
            label: Text(
              _isSelectionMode
                  ? "DELETE SELECTED (${_selectedIds.length})"
                  : "ADD PRODUCT",
              style: const TextStyle(
                fontFamily: 'Monocraft',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          body: RefreshIndicator(
            color: const Color(0xFF5B6EE1),
            onRefresh: _loadData,
            child: Column(
              children: [
                Header(
                  title: _isSelectionMode ? 'Selection' : 'Manage',
                  dark: isDarkMode,
                ),
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
                      onChanged: _filterProducts,
                      cursorColor: const Color(0xFF5B6EE1),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontFamily: 'Monocraft',
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        hintStyle: TextStyle(
                          fontFamily: 'Monocraft',
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.white38
                              : const Color(0xFF9D9D9D),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: _isSearchFocused
                              ? const Color(0xFF5B6EE1)
                              : (isDarkMode ? Colors.white38 : Colors.grey),
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty ||
                                _isSelectionMode
                            ? IconButton(
                                icon: Icon(
                                  _isSelectionMode
                                      ? Icons.close_rounded
                                      : Icons.close_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  if (_isSelectionMode) {
                                    _exitSelection();
                                  } else {
                                    _searchController.clear();
                                    _filterProducts('');
                                  }
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading && _filteredProducts.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5B6EE1),
                          ),
                        )
                      : _filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            "No products found",
                            style: TextStyle(
                              fontFamily: 'Monocraft',
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFF9D9D9D),
                            ),
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notif) {
                            if (notif is UserScrollNotification) {
                              if (notif.direction != ScrollDirection.idle) {
                                _fabTimer?.cancel();
                                if (_isFabExtended) {
                                  setState(() => _isFabExtended = false);
                                }
                              }
                            } else if (notif is ScrollEndNotification) {
                              _fabTimer?.cancel();
                              _fabTimer = Timer(const Duration(seconds: 1), () {
                                if (mounted && !_isFabExtended) {
                                  setState(() => _isFabExtended = true);
                                }
                              });
                            }
                            return true;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            controller: _scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.55,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) =>
                                _buildStockCard(_filteredProducts[index]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(Product product) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = _selectedIds.contains(product.id);
    return GestureDetector(
      onLongPress: () => _toggleSelection(product.id),
      onTap: () => _isSelectionMode ? _toggleSelection(product.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5B6EE1).withAlpha(40)
              : (isDarkMode
                    ? Colors.white.withAlpha(12)
                    : const Color(0xFFEEF2F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B6EE1)
                : (isDarkMode
                      ? Colors.white.withAlpha(20)
                      : Colors.transparent),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 12,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? Colors.black.withAlpha(50)
                            : Colors.transparent,
                        BlendMode.darken,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.white.withAlpha(10)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'Monocraft',
                              ),
                            ),
                            Text(
                              product.category.toUpperCase(),
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white38
                                    : Colors.grey[600],
                                fontSize: 9,
                                fontFamily: 'Monocraft',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatRupiah(product.price),
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFF8B9BFF)
                                    : const Color(0xFF5B6EE1),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                fontFamily: 'Monocraft',
                              ),
                            ),
                            Text(
                              "${product.stock}",
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Monocraft',
                                color: product.stock <= 5
                                    ? Colors.redAccent
                                    : (isDarkMode
                                          ? Colors.white70
                                          : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!_isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _cardActionButton(
                      Icons.edit_rounded,
                      Colors.blue,
                      () => _openFormOverlay(product),
                    ),
                    const SizedBox(width: 6),
                    _cardActionButton(
                      Icons.delete_outline_rounded,
                      Colors.redAccent,
                      () => _showDeleteConfirm(singleId: product.id),
                    ),
                  ],
                ),
              ),
            if (isSelected)
              const Positioned(
                top: 8,
                left: 8,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFF5B6EE1),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardActionButton(IconData icon, Color color, VoidCallback onTap) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black.withAlpha(160)
              : Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
