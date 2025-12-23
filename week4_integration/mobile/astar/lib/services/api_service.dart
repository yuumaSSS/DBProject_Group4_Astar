import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/products.dart';

class ApiService {
  final String baseUrl = "https://backend-astar.vercel.app";

  Future<List<Product>> fetchProducts() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    if (token == null) {
      throw Exception("You must login!");
    }

    final url = Uri.parse('$baseUrl/api/admin/products');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Product> products = body
          .map((dynamic item) => Product.fromJson(item))
          .toList();
      return products;
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }
}