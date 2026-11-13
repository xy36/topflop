import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/domain/product_category.dart';

/// Product data as delivered by Open Food Facts (or its sister projects).
class OffProduct {
  const OffProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.quantity,
    this.imageUrl,
    this.nutriScore,
    this.category = ProductCategory.other,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? imageUrl;
  final String? nutriScore;
  final ProductCategory category;
}

class OffLookupException implements Exception {
  const OffLookupException(this.cause);
  final Object cause;

  @override
  String toString() => 'OffLookupException: $cause';
}

/// Looks up barcodes on Open Food Facts. For non-food products it falls back
/// to Open Beauty Facts and Open Products Facts.
class OpenFoodFactsClient {
  OpenFoodFactsClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _hosts = [
    ('world.openfoodfacts.org', null),
    ('world.openbeautyfacts.org', ProductCategory.household),
    ('world.openproductsfacts.org', ProductCategory.household),
  ];

  static const _fields =
      'product_name,generic_name,brands,quantity,image_front_url,image_url,'
      'nutriscore_grade,categories_tags';

  /// OFF asks for a meaningful User-Agent.
  static const _userAgent = 'TopFlop/1.0 (Flutter; personal product ratings)';

  /// Returns `null` if the barcode is not known anywhere.
  /// Throws [OffLookupException] on network errors.
  Future<OffProduct?> lookup(String barcode, {String languageCode = 'de'}) async {
    for (final (host, fallbackCategory) in _hosts) {
      final product = await _lookupAt(host, barcode, languageCode, fallbackCategory);
      if (product != null) return product;
    }
    return null;
  }

  Future<OffProduct?> _lookupAt(
    String host,
    String barcode,
    String languageCode,
    ProductCategory? fallbackCategory,
  ) async {
    final uri = Uri.https(host, '/api/v2/product/$barcode.json', {
      'fields': '$_fields,product_name_$languageCode',
      'lc': languageCode,
    });

    final http.Response response;
    try {
      response = await _http.get(uri, headers: {'User-Agent': _userAgent}).timeout(const Duration(seconds: 8));
    } catch (e) {
      throw OffLookupException(e);
    }
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw OffLookupException('HTTP ${response.statusCode}');

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (json['status'] != 1) return null;
    final p = json['product'] as Map<String, dynamic>? ?? const {};

    final name = pickName([p['product_name_$languageCode'], p['product_name'], p['generic_name']]);
    if (name == null) return null;

    final tags = (p['categories_tags'] as List?)?.cast<String>() ?? const [];
    var category = ProductCategory.fromOffTags(tags);
    if (category == ProductCategory.other && fallbackCategory != null) category = fallbackCategory;

    final grade = _firstNonEmpty([p['nutriscore_grade']]);
    return OffProduct(
      barcode: barcode,
      name: name,
      brand: _firstNonEmpty([(p['brands'] as String?)?.split(',').first]),
      quantity: _firstNonEmpty([p['quantity']]),
      imageUrl: _firstNonEmpty([p['image_front_url'], p['image_url']]),
      nutriScore: grade != null && 'abcde'.contains(grade) && grade.length == 1 ? grade.toUpperCase() : null,
      category: category,
    );
  }

  /// Takes the first usable name. Some OFF entries contain retailer texts
  /// like "… 1L (1,29 € / 1 l) zzgl. Pfand 0,15 €" – those are skipped as
  /// long as there is a cleaner alternative.
  static String? pickName(List<Object?> candidates) {
    final names = [
      for (final c in candidates)
        if (c is String && c.trim().isNotEmpty) c.trim().replaceAll(RegExp(r'\s+'), ' '),
    ];
    return names.where((n) => !_looksLikeShopText(n)).firstOrNull ?? names.firstOrNull;
  }

  static final _shopText = RegExp(r'€|\bEUR\b|\bPfand\b|\bzzgl\.|\binkl\.|\d+\s*x\s*\d', caseSensitive: false);

  static bool _looksLikeShopText(String name) => name.length > 60 || _shopText.hasMatch(name);

  static String? _firstNonEmpty(List<Object?> values) {
    for (final v in values) {
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
