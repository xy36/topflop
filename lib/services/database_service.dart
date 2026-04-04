import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:topflop/hive_registrar.g.dart';

import '../models/product_item.dart';
import '../models/product_type.dart';

class DatabaseService {
  static const String _boxName = 'products';

  late Box<ProductItem> _box;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapters();
    _box = await Hive.openBox<ProductItem>(_boxName);
  }

  Future<void> addItem(ProductItem item) async => _box.put(item.id, item);
  Future<void> updateItem(ProductItem item) async => _box.put(item.id, item);
  Future<void> deleteItem(String id) async => _box.delete(id);

  ProductItem? getItem(String id) => _box.get(id);
  List<ProductItem> getAllItems() => _box.values.toList();

  List<ProductItem> searchItems(String query) {
    final q = query.toLowerCase();
    return _box.values.where((item) {
      return item.name.toLowerCase().contains(q) ||
          (item.brand?.toLowerCase().contains(q) ?? false) ||
          (item.store?.toLowerCase().contains(q) ?? false) ||
          (item.category?.toLowerCase().contains(q) ?? false) ||
          item.barcode.contains(q);
    }).toList();
  }

  ProductItem? findByBarcode(String barcode) {
    try {
      return _box.values.firstWhere((item) => item.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  List<String> getUniqueStores() =>
      _box.values
          .map((i) => i.store)
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<String> getUniqueBrands() =>
      _box.values
          .map((i) => i.brand)
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<ProductType> getUsedProductTypes() =>
      _box.values.map((i) => i.productType).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
}
