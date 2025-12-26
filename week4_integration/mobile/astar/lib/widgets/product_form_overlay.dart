import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/products.dart';
import '../services/api_service.dart';

class ProductFormOverlay extends StatefulWidget {
  final Product? product;
  final Function(Map<String, dynamic>) onSave;

  const ProductFormOverlay({super.key, this.product, required this.onSave});

  @override
  State<ProductFormOverlay> createState() => _ProductFormOverlayState();
}

class _ProductFormOverlayState extends State<ProductFormOverlay> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  final Map<String, FocusNode> _focusNodes = {
    'name': FocusNode(),
    'category': FocusNode(),
    'price': FocusNode(),
    'stock': FocusNode(),
  };

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _currentImageUrl = widget.product?.imageUrl;

    _focusNodes.forEach((key, node) {
      node.addListener(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _focusNodes.forEach((key, node) => node.dispose());
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (pickedFile.path.toLowerCase().endsWith('.webp')) {
        setState(() => _selectedImage = File(pickedFile.path));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Format file harus .webp",
              style: TextStyle(fontFamily: 'Monocraft'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                Text(
                  widget.product == null ? "ADD PRODUCT" : "EDIT PRODUCT",
                  style: const TextStyle(
                    fontFamily: 'Monocraft',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B6EE1),
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF5B6EE1).withAlpha(30),
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_currentImageUrl != null &&
                              _currentImageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: _currentImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search_rounded,
                                color: Color(0xFF5B6EE1),
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Upload Image",
                                style: TextStyle(
                                  fontFamily: 'Monocraft',
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedField(
                  _nameController,
                  _focusNodes['name']!,
                  "Product Name",
                  Icons.inventory_2_outlined,
                ),
                _buildAnimatedField(
                  _categoryController,
                  _focusNodes['category']!,
                  "Category",
                  Icons.category_outlined,
                ),
                _buildAnimatedField(
                  _priceController,
                  _focusNodes['price']!,
                  "Price",
                  Icons.payments_outlined,
                  isNumber: true,
                ),
                _buildAnimatedField(
                  _stockController,
                  _focusNodes['stock']!,
                  "Stock",
                  Icons.numbers_rounded,
                  isNumber: true,
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
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              HapticFeedback.mediumImpact();
                              setState(() => _isUploading = true);
                              try {
                                String imageUrl = _currentImageUrl ?? '';
                                if (_selectedImage != null) {
                                  imageUrl = await _apiService.uploadImage(
                                    _selectedImage!,
                                  );
                                }
                                widget.onSave({
                                  "name": _nameController.text,
                                  "category": _categoryController.text,
                                  "description": "Admin entry",
                                  "price": double.parse(_priceController.text),
                                  "image_url": imageUrl,
                                  "stock": int.parse(_stockController.text),
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isUploading = false);
                                }
                              }
                            }
                          },
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SAVE PRODUCT",
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

  Widget _buildAnimatedField(
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    final bool isFocused = focusNode.hasFocus;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFocused ? Colors.white : const Color(0xFFEEF2F6),
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
          style: const TextStyle(fontFamily: 'Monocraft', fontSize: 13),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: 'Monocraft',
              fontSize: 12,
              color: isFocused ? const Color(0xFF5B6EE1) : Colors.grey,
            ),
            errorStyle: const TextStyle(
              fontFamily: 'Monocraft',
              fontSize: 10,
              color: Colors.redAccent,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused ? const Color(0xFF5B6EE1) : Colors.grey,
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
