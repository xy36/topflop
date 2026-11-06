import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../db/database.dart';

/// Manueller Export/Import aller Daten als JSON-Datei.
///
/// Ergänzt das automatische System-Backup (Android Auto Backup / iCloud),
/// das die Datenbankdatei ohnehin sichert.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// 1: mehrere Bewertungen pro Produkt mit `storeId`.
  /// 2: eine Bewertung pro Produkt, Läden in `productStores`.
  static const formatVersion = 2;
  static const _lastExportKey = 'last_export';

  /// Android Auto Backup sichert maximal 25 MB pro App. Ab hier warnen wir.
  static const sizeWarningBytes = 20 * 1024 * 1024;

  /// Schreibt die Sicherung in eine temporäre Datei und gibt deren Pfad zurück.
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

  /// Ersetzt alle Daten durch den Inhalt der Sicherung.
  /// Wirft [FormatException], wenn die Datei keine gültige Sicherung ist.
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
    final stores = list('stores').map(Store.fromJson).toList();
    final rawRatings = list('ratings');

    final List<ProductStore> productStores;
    final List<Map<String, dynamic>> ratingRows;
    if (version == 1) {
      // Alte Sicherung: Läden hingen an den Bewertungen, mehrere pro Produkt.
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

  /// Größe der Datenbankdatei in Bytes (0, wenn nicht ermittelbar).
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
