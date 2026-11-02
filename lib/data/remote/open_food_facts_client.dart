import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/domain/product_category.dart';

/// Produktdaten, wie sie Open Food Facts (bzw. die Schwesterprojekte) liefert.
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

/// Fragt Barcodes bei Open Food Facts ab. Für Nicht-Lebensmittel wird auf
/// Open Beauty Facts und Open Products Facts ausgewichen.
class OpenFoodFactsClient {
  OpenFoodFactsClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _hosts = [
    ('world.openfoodfacts.org', null),
    ('world.openbeautyfacts.org', ProductCategory.household),
    ('world.openproductsfacts.org', ProductCategory.household),
  ];

  static const _fields = 'product_name,generic_name,brands,quantity,image_front_url,image_url,'
      'nutriscore_grade,categories_tags';

  /// OFF bittet um einen aussagekräftigen User-Agent.
  static const _userAgent = 'TopFlop/1.0 (Flutter; personal product ratings)';

  /// Liefert `null`, wenn der Barcode nirgends bekannt ist.
  /// Wirft [OffLookupException] bei Netzwerkfehlern.
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

    final name = _firstNonEmpty([p['product_name_$languageCode'], p['product_name'], p['generic_name']]);
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

  static String? _firstNonEmpty(List<Object?> values) {
    for (final v in values) {
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
