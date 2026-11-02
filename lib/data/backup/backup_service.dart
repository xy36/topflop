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

  static const formatVersion = 1;
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
    };

    final dir = await getTemporaryDirectory();
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final file = File('${dir.path}/topflop-backup-$date.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<void> markExported() => _db.into(_db.settings).insertOnConflictUpdate(
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

    List<Map<String, dynamic>> list(String key) => ((decoded as Map)[key] as List? ?? const []).cast<Map<String, dynamic>>();

    final products = list('products').map(Product.fromJson).toList();
    final stores = list('stores').map(Store.fromJson).toList();
    final ratings = list('ratings').map(Rating.fromJson).toList();

    await _db.transaction(() async {
      await _db.delete(_db.ratings).go();
      await _db.delete(_db.products).go();
      await _db.delete(_db.stores).go();
      await _db.batch((b) {
        b.insertAll(_db.products, products);
        b.insertAll(_db.stores, stores);
        b.insertAll(_db.ratings, ratings);
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
