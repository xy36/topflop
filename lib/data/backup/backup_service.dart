import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../db/database.dart';

/// Manual export/import of all data as a JSON file.
///
/// Complements the automatic system backup (Android Auto Backup / iCloud),
/// which backs up the database file anyway.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// 1: several ratings per product with `storeId`.
  /// 2: one rating per product, stores in `productStores`.
  /// 3: stores are chains, branches in `storeLocations`.
  /// 4: no more branches/locations.
  static const formatVersion = 4;
  static const _lastExportKey = 'last_export';

  /// Android Auto Backup stores at most 25 MB per app. Above this we warn.
  static const sizeWarningBytes = 20 * 1024 * 1024;

  /// Writes the backup to a temporary file and returns its path.
  Future<File> exportToFile() async {
    final data = {
      'app': 'topflop',
      'version': formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'products': [for (final p in await _db.select(_db.products).get()) p.toJson()],
      'stores': [for (final s in await _db.select(_db.stores).get()) s.toJson()],
      'ratings': [for (final r in await _db.select(_db.ratings).get()) r.toJson()],
      'productStores': [for (final ps in await _db.select(_db.productStores).get()) ps.toJson()],
    };

    final dir = await getTemporaryDirectory();
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final file = File('${dir.path}/topflop-backup-$date.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<void> markExported() => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: _lastExportKey, value: DateTime.now().toUtc().toIso8601String()),
      );

  Future<DateTime?> lastExport() async {
    final row = await (_db.select(_db.settings)..where((s) => s.key.equals(_lastExportKey))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value)?.toLocal();
  }

  /// Replaces all data with the contents of the backup.
  /// Throws [FormatException] if the file is not a valid backup.
  Future<void> importJson(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic> || decoded['app'] != 'topflop') {
      throw const FormatException('Keine TopFlop-Sicherung');
    }
    final version = decoded['version'];
    if (version is! int || version > formatVersion) {
      throw FormatException('Nicht unterstützte Version: $version');
    }

    List<Map<String, dynamic>> list(String key) =>
        ((decoded as Map)[key] as List? ?? const []).cast<Map<String, dynamic>>();

    final products = list('products').map(Product.fromJson).toList();
    final rawStores = list('stores');
    final rawRatings = list('ratings');

    // Up to version 2 a store was a branch: stores with the same name are
    // merged into one store. Coordinates and branches (version 3) are no
    // longer imported.
    final List<Store> stores;
    final storeIdMap = <int, int>{};
    if (version < 3) {
      final chainByName = <String, Map<String, dynamic>>{};
      for (final s in rawStores) {
        final key = (s['name'] as String).trim().toLowerCase();
        final chain = chainByName.putIfAbsent(key, () => s);
        storeIdMap[s['id'] as int] = chain['id'] as int;
      }
      stores = chainByName.values.map(Store.fromJson).toList();
    } else {
      stores = rawStores.map(Store.fromJson).toList();
    }

    List<ProductStore> productStores;
    final List<Map<String, dynamic>> ratingRows;
    if (version == 1) {
      // Old backup: stores were attached to ratings, several per product.
      productStores = {
        for (final r in rawRatings)
          if (r['storeId'] != null) (r['productId'] as int, r['storeId'] as int),
      }.map((e) => ProductStore(productId: e.$1, storeId: e.$2)).toList();
      final newest = <int, Map<String, dynamic>>{};
      for (final r in rawRatings) {
        final current = newest[r['productId'] as int];
        if (current == null || (r['ratedAt'] as int) >= (current['ratedAt'] as int)) newest[r['productId'] as int] = r;
      }
      ratingRows = newest.values.toList();
    } else {
      productStores = list('productStores').map(ProductStore.fromJson).toList();
      ratingRows = rawRatings;
    }
    final ratings = ratingRows.map(Rating.fromJson).toList();
    // Point the assignments to the merged chains, without duplicates.
    productStores = {for (final ps in productStores) (ps.productId, storeIdMap[ps.storeId] ?? ps.storeId)}
        .map((e) => ProductStore(productId: e.$1, storeId: e.$2))
        .toList();

    await _db.transaction(() async {
      await _db.delete(_db.productStores).go();
      await _db.delete(_db.ratings).go();
      await _db.delete(_db.products).go();
      await _db.delete(_db.stores).go();
      await _db.batch((b) {
        b.insertAll(_db.products, products);
        b.insertAll(_db.stores, stores);
        b.insertAll(_db.ratings, ratings);
        b.insertAll(_db.productStores, productStores);
      });
    });
  }

  /// Size of the database file in bytes (0 if it cannot be determined).
  Future<int> databaseSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${AppDatabase.fileName}.sqlite');
      return await file.exists() ? await file.length() : 0;
    } catch (_) {
      return 0;
    }
  }
}
