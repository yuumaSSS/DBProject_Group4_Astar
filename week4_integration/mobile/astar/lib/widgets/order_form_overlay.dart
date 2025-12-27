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
  final _productIdController = TextEditingController();
  final _qtyController = TextEditingController();
  String _selectedStatus = 'pending';
  bool _isSaving = false;

  final Map<String, FocusNode> _focusNodes = {
    'user': FocusNode(),
    'product': FocusNode(),
    'qty': FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    _focusNodes.forEach((key, node) => node.addListener(() => setState(() {})));
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _productIdController.dispose();
    _qtyController.dispose();
    _focusNodes.forEach((key, node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
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
                    color: Colors.grey.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "NEW MANUAL ORDER",
                  style: TextStyle(
                    fontFamily: 'Monocraft',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B6EE1),
                  ),
                ),
                const SizedBox(height: 25),
                _buildField(
                  _userIdController,
                  _focusNodes['user']!,
                  "User ID",
                  Icons.person_outline,
                ),
                _buildField(
                  _productIdController,
                  _focusNodes['product']!,
                  "Product ID",
                  Icons.inventory_2_outlined,
                  isNum: true,
                ),
                _buildField(
                  _qtyController,
                  _focusNodes['qty']!,
                  "Quantity",
                  Icons.shopping_cart_outlined,
                  isNum: true,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  dropdownColor: widget.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  decoration: InputDecoration(
                    labelText: "Initial Status",
                    labelStyle: TextStyle(
                      fontFamily: 'Monocraft',
                      fontSize: 12,
                      color: widget.dark
                          ? Colors.white.withAlpha(100)
                          : Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                    border: InputBorder.none,
                  ),
                  items: ['pending', 'process']
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Monocraft',
                              fontSize: 13,
                              color: widget.dark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
                const SizedBox(height: 30),
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
                    onPressed: _isSaving
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final int prodId = int.parse(
                                _productIdController.text,
                              );
                              final int qty = int.parse(_qtyController.text);

                              final product = widget.products
                                  .cast<Product?>()
                                  .firstWhere(
                                    (p) => p?.id == prodId,
                                    orElse: () => null,
                                  );

                              if (product == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "PRODUCT ID NOT FOUND",
                                      style: TextStyle(fontFamily: 'Monocraft'),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => _isSaving = true);
                              widget.onSave({
                                "user_id": _userIdController.text,
                                "product_id": prodId,
                                "quantity": qty,
                                "total_amount": product.price * qty,
                                "status": _selectedStatus,
                                "order_date": DateTime.now().toIso8601String(),
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
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    FocusNode fn,
    String label,
    IconData icon, {
    bool isNum = false,
  }) {
    final bool isFocused = fn.hasFocus;
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
        ),
        child: TextFormField(
          controller: ctrl,
          focusNode: fn,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
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
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
      ),
    );
  }
}
