import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/products.dart';

class OrderFormOverlay extends StatefulWidget {
  final List<Product> products;
  final Function(Map<String, dynamic>) onSave;
  final bool dark;

  const OrderFormOverlay({
    super.key,
    required this.products,
    required this.onSave,
    required this.dark,
  });

  @override
  State<OrderFormOverlay> createState() => _OrderFormOverlayState();
}

class _OrderFormOverlayState extends State<OrderFormOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _qtyController = TextEditingController();

  final Map<String, FocusNode> _focusNodes = {
    'user': FocusNode(),
    'qty': FocusNode(),
  };

  Product? _selectedProduct;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _focusNodes.forEach((key, node) => node.addListener(() => setState(() {})));
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _qtyController.dispose();
    _focusNodes.forEach((key, node) => node.dispose());
    super.dispose();
  }

  bool _isValidUUID(String uuid) {
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(uuid);
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.dark ? const Color(0xFF1A1C26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "SELECT PRODUCT",
              style: TextStyle(
                fontFamily: 'Monocraft',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: widget.products.isEmpty
                  ? const Center(
                      child: Text(
                        "NO PRODUCTS AVAILABLE",
                        style: TextStyle(fontFamily: 'Monocraft'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.products.length,
                      itemBuilder: (context, i) {
                        final p = widget.products[i];
                        return ListTile(
                          title: Text(
                            p.name,
                            style: TextStyle(
                              fontFamily: 'Monocraft',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            "Price: Rp ${p.price.toInt()} | Stock: ${p.stock}",
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Monocraft',
                            ),
                          ),
                          onTap: () {
                            setState(() => _selectedProduct = p);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalCalc =
        (_selectedProduct?.price ?? 0) *
        (int.tryParse(_qtyController.text) ?? 0);

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: widget.dark ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: widget.dark
                          ? Colors.white.withAlpha(40)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "NEW MANUAL ORDER",
                    style: TextStyle(
                      fontFamily: 'Monocraft',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B6EE1),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildAnimatedField(
                    _userIdController,
                    _focusNodes['user']!,
                    "Customer UUID",
                    Icons.fingerprint,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      if (!_isValidUUID(v)) return "Invalid UUID Format";
                      return null;
                    },
                  ),
                  _buildProductSelector(),
                  _buildAnimatedField(
                    _qtyController,
                    _focusNodes['qty']!,
                    "Quantity",
                    Icons.shopping_cart_outlined,
                    isNumber: true,
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B6EE1).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF5B6EE1).withAlpha(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL AMOUNT",
                          style: TextStyle(
                            fontFamily: 'Monocraft',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rp ${totalCalc.toInt()}",
                          style: const TextStyle(
                            fontFamily: 'Monocraft',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B6EE1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B6EE1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: (_isSaving || _selectedProduct == null)
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.mediumImpact();
                                setState(() => _isSaving = true);

                                final int cleanTotal = totalCalc.toInt();

                                widget.onSave({
                                  "user_id": _userIdController.text.trim(),
                                  "product_id": _selectedProduct!.id,
                                  "quantity": int.parse(_qtyController.text),
                                  "total_amount": cleanTotal,
                                  "status": "pending",
                                });
                              }
                            },
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SUBMIT ORDER",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Monocraft',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: _showProductPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.dark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: widget.dark
                    ? Colors.white.withAlpha(100)
                    : const Color(0xFF9D9D9D),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product",
                      style: TextStyle(
                        fontFamily: 'Monocraft',
                        fontSize: 10,
                        color: widget.dark
                            ? Colors.white.withAlpha(100)
                            : const Color(0xFF9D9D9D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedProduct?.name ?? "Select Product",
                      style: TextStyle(
                        fontFamily: 'Monocraft',
                        fontSize: 13,
                        color: _selectedProduct == null
                            ? (widget.dark ? Colors.grey : Colors.grey)
                            : (widget.dark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF5B6EE1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField(
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    IconData icon, {
    bool isNumber = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final bool isFocused = focusNode.hasFocus;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFocused
              ? (widget.dark ? const Color(0xFF2C2C2C) : Colors.white)
              : (widget.dark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFEEF2F6)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFocused ? const Color(0xFF5B6EE1) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF5B6EE1).withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'Monocraft',
            fontSize: 13,
            color: widget.dark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: 'Monocraft',
              fontSize: 12,
              color: isFocused
                  ? const Color(0xFF5B6EE1)
                  : (widget.dark
                        ? Colors.white.withAlpha(100)
                        : const Color(0xFF9D9D9D)),
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused
                  ? const Color(0xFF5B6EE1)
                  : (widget.dark
                        ? Colors.white.withAlpha(100)
                        : const Color(0xFF9D9D9D)),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator:
              validator ?? (v) => v == null || v.isEmpty ? "Required" : null,
        ),
      ),
    );
  }
}
