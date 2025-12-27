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
  Product? _selectedProduct;
  bool _isSaving = false;

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
                            style: const TextStyle(
                              fontFamily: 'Monocraft',
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            "Price: Rp ${p.price.toInt()} | Stock: ${p.stock}",
                            style: const TextStyle(fontSize: 10),
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
    // 1. Variabel ini bernama 'totalCalc'
    final double totalCalc =
        (_selectedProduct?.price ?? 0) *
        (int.tryParse(_qtyController.text) ?? 0);

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
                TextFormField(
                  controller: _userIdController,
                  style: TextStyle(
                    fontFamily: 'Monocraft',
                    fontSize: 13,
                    color: widget.dark ? Colors.white : Colors.black,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Customer UUID",
                    hintText: "c4f52e1d-03d3...",
                    prefixIcon: Icon(Icons.fingerprint, size: 20),
                    border: InputBorder.none,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Required";
                    if (!_isValidUUID(v)) return "Invalid UUID Format";
                    return null;
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF5B6EE1),
                  ),
                  title: Text(
                    _selectedProduct?.name ?? "Select Product",
                    style: TextStyle(
                      fontFamily: 'Monocraft',
                      fontSize: 13,
                      color: widget.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: _showProductPicker,
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {}),
                  style: TextStyle(
                    fontFamily: 'Monocraft',
                    fontSize: 13,
                    color: widget.dark ? Colors.white : Colors.black,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                    prefixIcon: Icon(Icons.shopping_cart_outlined, size: 20),
                    border: InputBorder.none,
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6EE1).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL",
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
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B6EE1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: (_isSaving || _selectedProduct == null)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isSaving = true);

                              // FIX 1: Format UTC Timezone (Z)
                              final String isoDate = DateTime.now()
                                  .toUtc()
                                  .toIso8601String();

                              // FIX 2: Gunakan 'totalCalc' bukan 'total'
                              // Convert ke int lalu ke String agar bersih (contoh: "150000")
                              final String cleanTotal = totalCalc
                                  .toInt()
                                  .toString();

                              widget.onSave({
                                "user_id": _userIdController.text.trim(),
                                "product_id": _selectedProduct!.id,
                                "quantity": int.parse(_qtyController.text),
                                "total_amount": cleanTotal,
                                "status": "pending",
                                "order_date": isoDate,
                              });
                            }
                          },
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SUBMIT",
                            style: TextStyle(
                              fontFamily: 'Monocraft',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
}
