import 'package:drift/drift.dart';

import '../db/database.dart';
import 'models.dart';
import 'product_repository.dart';

/// Stores – meaning chains like "Lidl", without individual branches.
class StoreRepository {
  StoreRepository(this._db, this._products);

  final AppDatabase _db;
  final ProductRepository _products;

  /// Comparison key for chain names: first word, lower case, no punctuation.
  /// That way "ALDI SÜD", "Aldi" and "Aldi Bahnhofstraße" end up as the same chain.
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

  /// Existing chain with a matching name (see [chainKey]) or `null`.
  Future<Store?> findChain(String name) async {
    final key = chainKey(name);
    if (key.isEmpty) return null;
    return (await allStores()).where((s) => chainKey(s.name) == key).firstOrNull;
  }

  /// Returns the matching chain or creates a new one.
  Future<int> findOrCreateChain(String name) async =>
      (await findChain(name))?.id ?? await _db.into(_db.stores).insert(StoresCompanion.insert(name: name.trim()));

  /// Creates the store or returns the existing chain with the same name.
  Future<int> addStore({required String name}) => findOrCreateChain(name);

  Future<void> renameStore(int id, String name) =>
      (_db.update(_db.stores)..where((s) => s.id.equals(id))).write(StoresCompanion(name: Value(name.trim())));

  /// Deletes the store. Ratings are kept; only the assignment to this
  /// store is removed.
  Future<void> deleteStore(int id) => (_db.delete(_db.stores)..where((s) => s.id.equals(id))).go();
}
