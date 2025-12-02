class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? 0,
      name: json['product_name'] ?? 'Tanpa Nama',
      category: json['category'] ?? '-',
      price: (json['unit_price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }
}