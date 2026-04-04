import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_type.dart';

class OpenProduct {
  final String barcode;
  final String? name;
  final String? brand;
  final String? imageUrl;
  final String? ingredients;
  final String? category;
  final ProductType productType;

  OpenProduct({
    required this.barcode,
    this.name,
    this.brand,
    this.imageUrl,
    this.ingredients,
    this.category,
    required this.productType,
  });

  factory OpenProduct._fromJson(
    Map<String, dynamic> json,
    ProductType productType,
  ) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      return OpenProduct(
        barcode: json['code'] ?? '',
        productType: productType,
      );
    }
    return OpenProduct(
      barcode: json['code'] ?? product['code'] ?? '',
      name: product['product_name'] ??
          product['product_name_de'] ??
          product['product_name_en'],
      brand: product['brands'],
      imageUrl: product['image_url'] ?? product['image_front_url'],
      ingredients: product['ingredients_text'] ?? product['ingredients_text_de'],
      category: product['categories'],
      productType: productType,
    );
  }

  factory OpenProduct._fromSearchJson(
    Map<String, dynamic> product,
    ProductType productType,
  ) {
    return OpenProduct(
      barcode: product['code'] ?? '',
      name: product['product_name'] ??
          product['product_name_de'] ??
          product['product_name_en'],
      brand: product['brands'],
      imageUrl: product['image_url'] ??
          product['image_front_url'] ??
          product['image_front_small_url'],
      ingredients:
          product['ingredients_text'] ?? product['ingredients_text_de'],
      category: product['categories'],
      productType: productType,
    );
  }
}

class OpenProductsService {
  static final OpenProductsService _instance = OpenProductsService._internal();
  factory OpenProductsService() => _instance;
  OpenProductsService._internal();

  static const _headers = {
    'User-Agent': 'JaninesFoodApp/1.0 (Flutter App)',
  };

  static const _databases = {
    ProductType.food: 'world.openfoodfacts.org',
    ProductType.beauty: 'world.openbeautyfacts.org',
    ProductType.household: 'world.openproductsfacts.org',
    ProductType.petFood: 'world.openpetfoodfacts.org',
  };

  /// Sucht den Barcode in allen Datenbanken der Reihe nach.
  /// Gibt das erste Ergebnis zurück, das einen Namen hat.
  Future<OpenProduct?> getProductByBarcode(String barcode) async {
    for (final entry in _databases.entries) {
      final result = await _fetchBarcode(barcode, entry.key, entry.value);
      if (result != null && result.name != null && result.name!.isNotEmpty) {
        return result;
      }
    }
    return null;
  }

  Future<OpenProduct?> _fetchBarcode(
    String barcode,
    ProductType type,
    String host,
  ) async {
    try {
      final url =
          Uri.parse('https://$host/api/v2/product/$barcode.json');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1) {
          return OpenProduct._fromJson(data, type);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sucht in einer bestimmten Datenbank nach Produkten.
  Future<List<OpenProduct>> searchProducts(
    String query,
    ProductType productType, {
    int pageSize = 20,
  }) async {
    if (query.trim().isEmpty) return [];
    final host = _databases[productType];
    if (host == null) return [];

    try {
      final url =
          Uri.parse('https://$host/cgi/search.pl').replace(queryParameters: {
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': pageSize.toString(),
        'sort_by': 'popularity_key',
        'lc': 'de',
      });

      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>?;
        if (products != null) {
          return products
              .map((p) => OpenProduct._fromSearchJson(
                    p as Map<String, dynamic>,
                    productType,
                  ))
              .where((p) => p.name != null && p.name!.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
