import 'package:drift/drift.dart';

import '../db/database.dart';
import 'models.dart';
import 'product_repository.dart';

/// Läden – gemeint sind Ketten wie „Lidl“, ohne einzelne Filialen.
class StoreRepository {
  StoreRepository(this._db, this._products);

  final AppDatabase _db;
  final ProductRepository _products;

  /// Vergleichsschlüssel für Kettennamen: erstes Wort, klein, ohne Satzzeichen.
  /// So landen „ALDI SÜD“, „Aldi“ und „Aldi Bahnhofstraße“ bei derselben Kette.
  static String chainKey(String name) {
    final firstWord = name.trim().toLowerCase().split(RegExp(r'\s+')).first;
    return firstWord.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
  }

  Stream<List<StoreSummary>> watchSummaries() async* {
    yield await loadSummaries();
    final tables = <TableInfo>[_db.products, _db.ratings, _db.stores, _db.productStores];
    await for (final _ in _db.tableUpdates(TableUpdateQuery.onAllTables(tables))) {
      yield await loadSummaries();
    }
  }

  Future<List<StoreSummary>> loadSummaries() async {
    final stores = await (_db.select(_db.stores)..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
    final products = await _products.loadSummaries();
    return [
      for (final store in stores)
        StoreSummary(
          store: store,
          products: products.where((p) => p.stores.any((s) => s.id == store.id)).toList()
            ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0)),
        ),
    ];
  }

  Future<List<Store>> allStores() => (_db.select(_db.stores)..orderBy([(s) => OrderingTerm.asc(s.name)])).get();

  /// Vorhandene Kette mit passendem Namen (siehe [chainKey]) oder `null`.
  Future<Store?> findChain(String name) async {
    final key = chainKey(name);
    if (key.isEmpty) return null;
    return (await allStores()).where((s) => chainKey(s.name) == key).firstOrNull;
  }

  /// Liefert die passende Kette oder legt sie neu an.
  Future<int> findOrCreateChain(String name) async =>
      (await findChain(name))?.id ?? await _db.into(_db.stores).insert(StoresCompanion.insert(name: name.trim()));

  /// Legt den Laden an oder liefert die vorhandene Kette gleichen Namens.
  Future<int> addStore({required String name}) => findOrCreateChain(name);

  Future<void> renameStore(int id, String name) =>
      (_db.update(_db.stores)..where((s) => s.id.equals(id))).write(StoresCompanion(name: Value(name.trim())));

  /// Löscht den Laden. Bewertungen bleiben erhalten; nur die
  /// Zuordnung zu diesem Laden entfällt.
  Future<void> deleteStore(int id) => (_db.delete(_db.stores)..where((s) => s.id.equals(id))).go();
}
