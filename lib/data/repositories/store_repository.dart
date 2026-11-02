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
    await for (final _ in _db.tableUpdates(TableUpdateQuery.onAllTables([_db.products, _db.ratings, _db.stores]))) {
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
          products: products.where((p) => p.ratings.any((r) => r.store?.id == store.id)).toList()
            ..sort((a, b) => _scoreAt(b, store.id).compareTo(_scoreAt(a, store.id))),
        ),
    ];
  }

  /// Durchschnitt der Bewertungen eines Produkts in einem bestimmten Laden.
  static double _scoreAt(ProductSummary p, int storeId) {
    final scores = [
      for (final r in p.ratings)
        if (r.store?.id == storeId) r.rating.score,
    ];
    return scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
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

  Future<void> deleteStore(int id) => (_db.delete(_db.stores)..where((s) => s.id.equals(id))).go();
}
