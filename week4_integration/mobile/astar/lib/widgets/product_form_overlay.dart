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
  final bool dark;

  const ProductFormOverlay({
    super.key,
    this.product,
    required this.onSave,
    required this.dark,
  });

  @override
  State<ProductFormOverlay> createState() => _ProductFormOverlayState();
}

class _ProductFormOverlayState extends State<ProductFormOverlay> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  final Map<String, FocusNode> _focusNodes = {
    'name': FocusNode(),
    'category': FocusNode(),
    'desc': FocusNode(),
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
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _currentImageUrl = widget.product?.imageUrl;
    _focusNodes.forEach((key, node) => node.addListener(() => setState(() {})));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _focusNodes.forEach((key, node) => node.dispose());
    super.dispose();
  }

  String _sanitizeError(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains("http") ||
        lowerError.contains("vercel") ||
        lowerError.contains("supabase") ||
        lowerError.contains("socketexception")) {
      return "NETWORK ERROR: FAILED TO SAVE DATA";
    }
    return error;
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
          SnackBar(
            content: Text(
              "File format must be .webp",
              style: TextStyle(
                fontFamily: 'Monocraft',
                color: widget.dark ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        color: widget.dark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(
                            0xFF5B6EE1,
                          ).withAlpha(widget.dark ? 60 : 30),
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_search_rounded,
                                  color: Color(0xFF5B6EE1),
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Upload Image",
                                  style: TextStyle(
                                    fontFamily: 'Monocraft',
                                    fontSize: 10,
                                    color: widget.dark
                                        ? Colors.white.withAlpha(100)
                                        : const Color(0xFF9D9D9D),
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
                    _descController,
                    _focusNodes['desc']!,
                    "Description",
                    Icons.description_outlined,
                    maxLines: 3,
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
                                      _nameController.text,
                                    );
                                  }
                                  widget.onSave({
                                    "name": _nameController.text,
                                    "category": _categoryController.text,
                                    "description": _descController.text,
                                    "price": double.parse(
                                      _priceController.text,
                                    ),
                                    "image_url": imageUrl,
                                    "stock": int.parse(_stockController.text),
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _sanitizeError(
                                          e.toString(),
                                        ).toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Monocraft',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
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
      ),
    );
  }

  Widget _buildAnimatedField(
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
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
          maxLines: maxLines,
          keyboardType: isNumber
              ? TextInputType.number
              : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          style: TextStyle(
            fontFamily: 'Monocraft',
            fontSize: 13,
            color: widget.dark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            alignLabelWithHint: maxLines > 1,
            labelStyle: TextStyle(
              fontFamily: 'Monocraft',
              fontSize: 12,
              color: isFocused
                  ? const Color(0xFF5B6EE1)
                  : (widget.dark
                        ? Colors.white.withAlpha(100)
                        : const Color(0xFF9D9D9D)),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                bottom: maxLines > 1 ? (maxLines * 8.0) : 0,
              ),
              child: Icon(
                icon,
                color: isFocused
                    ? const Color(0xFF5B6EE1)
                    : (widget.dark
                          ? Colors.white.withAlpha(100)
                          : const Color(0xFF9D9D9D)),
                size: 20,
              ),
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
