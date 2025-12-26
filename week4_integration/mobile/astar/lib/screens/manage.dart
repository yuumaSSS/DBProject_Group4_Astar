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
  late Future<List<Product>> _productsFuture;
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _fabTimer;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isInit = true;
  bool _isFabExtended = true;
  bool _isLoading = false;
  bool _isSearchFocused = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
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
        _productsFuture = Future.value(_allProducts);
      } else {
        _loadData();
      }
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _productsFuture = _apiService.fetchProducts();
    });

    try {
      final products = await _productsFuture;
      setState(() {
        _allProducts = products;
        _filterProducts(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
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

  void _openFormOverlay([Product? product]) {
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Action failed: $e")));
          }
        },
      ),
    );
  }

  void _showDeleteConfirm(int id) {
    HapticFeedback.heavyImpact();
    showDialog(
      useSafeArea: true,
      barrierColor: Colors.black.withAlpha(178),
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEEF2F6), width: 1),
          ),
          title: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 40,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CONFIRM DELETE",
                style: TextStyle(
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "This action will permanently remove the item from stock database.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Monocraft',
                  fontSize: 12,
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
                  color: Color(0xFF455CE7),
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.pop(context);
                try {
                  await _apiService.deleteProduct(id);
                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
                }
              },
              child: const Text(
                "DELETE",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.w600,
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
    super.build(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          isExtended: _isFabExtended,
          backgroundColor: const Color(0xFF5B6EE1),
          onPressed: _openFormOverlay,
          icon: const Icon(Icons.add_box_rounded, color: Colors.white),
          label: const Text(
            "ADD PRODUCT",
            style: TextStyle(
              fontFamily: 'Monocraft',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        body: RefreshIndicator(
          color: const Color(0xFF5B6EE1),
          backgroundColor: Colors.white,
          onRefresh: _loadData,
          child: Column(
            children: [
              const Header(title: 'Manage'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: _isSearchFocused
                        ? Colors.white
                        : const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSearchFocused
                          ? const Color(0xFF5B6EE1)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: _isSearchFocused
                        ? [
                            BoxShadow(
                              color: const Color(0xFF5B6EE1).withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _filterProducts,
                    style: const TextStyle(
                      fontFamily: 'Monocraft',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      hintStyle: const TextStyle(
                        fontFamily: 'Monocraft',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      prefixIcon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.search,
                          key: ValueKey(_isSearchFocused),
                          color: _isSearchFocused
                              ? const Color(0xFF5B6EE1)
                              : Colors.grey,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                _searchController.clear();
                                _filterProducts('');
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
                child: _isLoading && _filteredProducts.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5B6EE1),
                        ),
                      )
                    : _filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(
                            fontFamily: 'Monocraft',
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is UserScrollNotification) {
                            if (scrollNotification.direction ==
                                    ScrollDirection.forward ||
                                scrollNotification.direction ==
                                    ScrollDirection.reverse) {
                              _fabTimer?.cancel();
                              if (_isFabExtended) {
                                setState(() => _isFabExtended = false);
                              }
                            }
                          } else if (scrollNotification
                              is ScrollEndNotification) {
                            _fabTimer?.cancel();
                            _fabTimer = Timer(const Duration(seconds: 1), () {
                              if (mounted && !_isFabExtended) {
                                setState(() => _isFabExtended = true);
                              }
                            });
                          }
                          return true;
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.52,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (context, index) =>
                                      _buildStockCard(_filteredProducts[index]),
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    // Mengoptimalkan penggunaan RAM dengan membatasi ukuran cache di memori
                    memCacheHeight: 400,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.withAlpha(50),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5B6EE1),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.withAlpha(30),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Monocraft',
                            ),
                          ),
                          Text(
                            product.category,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
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
                            style: const TextStyle(
                              color: Color(0xFF455CE7),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'Monocraft',
                            ),
                          ),
                          Text(
                            "${product.stock} pcs",
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Monocraft',
                              color: product.stock <= 5
                                  ? Colors.red
                                  : Colors.black,
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
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _cardActionButton(Icons.edit, Colors.blue, () {
                  HapticFeedback.selectionClick();
                  _openFormOverlay(product);
                }),
                const SizedBox(width: 5),
                _cardActionButton(Icons.delete, Colors.red, () {
                  HapticFeedback.heavyImpact();
                  _showDeleteConfirm(product.id);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
