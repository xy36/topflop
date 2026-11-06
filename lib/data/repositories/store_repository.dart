import 'package:drift/drift.dart';

import '../db/database.dart';
import 'models.dart';
import 'product_repository.dart';

class StoreRepository {
  StoreRepository(this._db, this._products);

  final AppDatabase _db;
  final ProductRepository _products;

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

  Future<List<Store>> allStores() => _db.select(_db.stores).get();

  Future<int> addStore({required String name, String? address, double? latitude, double? longitude}) => _db
      .into(_db.stores)
      .insert(
        StoresCompanion.insert(
          name: name,
          address: Value(address),
          latitude: Value(latitude),
          longitude: Value(longitude),
        ),
      );

  Future<void> updateStore(int id, {required String name, String? address, double? latitude, double? longitude}) =>
      (_db.update(_db.stores)..where((s) => s.id.equals(id))).write(
        StoresCompanion(
          name: Value(name),
          address: Value(address),
          latitude: Value(latitude),
          longitude: Value(longitude),
        ),
      );

  /// Bewertungen bleiben erhalten; nur die Zuordnung zu diesem Laden entfällt.
  Future<void> deleteStore(int id) => (_db.delete(_db.stores)..where((s) => s.id.equals(id))).go();
}
