class Order {
  final int id;
  final DateTime orderDate;
  final double totalAmount;
  final int quantity;
  final String status;
  final String customerName;
  final String phoneNumber;
  final String productName;
  final String imageUrl;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.quantity,
    required this.status,
    required this.customerName,
    required this.phoneNumber,
    required this.productName,
    required this.imageUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['order_id'],
      orderDate: DateTime.parse(json['order_date']),
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      quantity: json['quantity'],
      status: json['status'],
      customerName: json['customer_name'] ?? 'N/A',
      phoneNumber: json['phone_number'] ?? 'N/A',
      productName: json['product_name'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
