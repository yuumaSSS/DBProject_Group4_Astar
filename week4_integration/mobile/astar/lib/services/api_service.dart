import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/products.dart';

class ApiService {
  final String baseUrl = "https://backend-astar.vercel.app";
  final _supabase = Supabase.instance.client;

  Map<String, String> _getHeaders() {
    final session = _supabase.auth.currentSession;
    final token = session?.accessToken;
    if (token == null) throw Exception("Unauthorized");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<String> uploadImage(File file) async {
    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.webp';
    final path = fileName;

    await _supabase.storage.from('products').upload(path, file);
    return _supabase.storage.from('products').getPublicUrl(path);
  }

  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('$baseUrl/api/admin/products');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/admin/products');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create");
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/admin/products/$id');
    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) throw Exception("Failed to update");
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/api/admin/products/$id');
    final response = await http.delete(url, headers: _getHeaders());
    if (response.statusCode != 200) throw Exception("Failed to delete");
  }
}
