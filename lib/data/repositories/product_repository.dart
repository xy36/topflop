import 'package:drift/drift.dart';

import '../../core/domain/product_category.dart';
import '../db/database.dart';
import '../remote/open_food_facts_client.dart';
import 'models.dart';

class ProductRepository {
  ProductRepository(this._db);

  final AppDatabase _db;

  Stream<void> get _changes async* {
    yield null;
    yield* _db.tableUpdates(TableUpdateQuery.onAllTables([_db.products, _db.ratings, _db.stores, _db.productStores]));
  }

  /// All products, most recently rated first.
  Stream<List<ProductSummary>> watchSummaries() => _changes.asyncMap((_) => loadSummaries());

  Stream<ProductSummary?> watchProduct(int id) => _changes.asyncMap((_) => loadProduct(id));

  Future<List<ProductSummary>> loadSummaries() async {
    final products = await _db.select(_db.products).get();
    final ratings = {for (final r in await _db.select(_db.ratings).get()) r.productId: r};
    final stores = await _storesByProduct();
    return [
      for (final p in products) ProductSummary(product: p, rating: ratings[p.id], stores: stores[p.id] ?? const []),
    ]..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  Future<ProductSummary?> loadProduct(int id) async {
    final product = await (_db.select(_db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
    if (product == null) return null;
    final rating = await findRating(id);
    final stores = await _storesByProduct(productId: id);
    return ProductSummary(product: product, rating: rating, stores: stores[id] ?? const []);
  }

  Future<ProductSummary?> findByBarcode(String barcode) async {
    final product = await (_db.select(_db.products)..where((p) => p.barcode.equals(barcode))).getSingleOrNull();
    return product == null ? null : loadProduct(product.id);
  }

  Future<Map<int, List<Store>>> _storesByProduct({int? productId}) async {
    final query = _db.select(_db.productStores).join([
      innerJoin(_db.stores, _db.stores.id.equalsExp(_db.productStores.storeId)),
    ]);
    if (productId != null) query.where(_db.productStores.productId.equals(productId));
    query.orderBy([OrderingTerm.asc(_db.stores.name)]);

    final result = <int, List<Store>>{};
    for (final row in await query.get()) {
      result.putIfAbsent(row.readTable(_db.productStores).productId, () => []).add(row.readTable(_db.stores));
    }
    return result;
  }

  /// Creates the product or updates the OFF data of an existing one.
  Future<int> upsertFromOff(OffProduct off) async {
    final existing = await (_db.select(_db.products)..where((p) => p.barcode.equals(off.barcode))).getSingleOrNull();
    final companion = ProductsCompanion(
      barcode: Value(off.barcode),
      name: Value(off.name),
      brand: Value(off.brand),
      quantity: Value(off.quantity),
      imageUrl: Value(off.imageUrl),
      nutriScore: Value(off.nutriScore),
      category: Value(off.category.name),
    );
    if (existing != null) {
      await (_db.update(_db.products)..where((p) => p.id.equals(existing.id))).write(companion);
      return existing.id;
    }
    return _db.into(_db.products).insert(companion);
  }

  Future<int> createManual({
    required String name,
    String? brand,
    String? quantity,
    String? barcode,
    required ProductCategory category,
  }) => _db
      .into(_db.products)
      .insert(
        ProductsCompanion.insert(
          name: name,
          brand: Value(brand),
          quantity: Value(quantity),
          barcode: Value(barcode),
          category: Value(category.name),
        ),
      );

  Future<void> setFavorite(int productId, bool favorite) => (_db.update(
    _db.products,
  )..where((p) => p.id.equals(productId))).write(ProductsCompanion(isFavorite: Value(favorite)));

  Future<void> deleteProduct(int productId) => (_db.delete(_db.products)..where((p) => p.id.equals(productId))).go();

  Future<Rating?> findRating(int productId) =>
      (_db.select(_db.ratings)..where((r) => r.productId.equals(productId))).getSingleOrNull();

  /// Saves the rating of a product (new or overwriting) and sets the
  /// stores that carry the product.
  Future<void> saveRating({
    required int productId,
    required int score,
    required bool wouldBuyAgain,
    required Set<int> storeIds,
    int? priceCents,
    String? note,
  }) => _db.transaction(() async {
    final values = RatingsCompanion(
      score: Value(score),
      wouldBuyAgain: Value(wouldBuyAgain),
      priceCents: Value(priceCents),
      note: Value(note),
      ratedAt: Value(DateTime.now()),
    );
    final existing = await findRating(productId);
    if (existing == null) {
      await _db.into(_db.ratings).insert(values.copyWith(productId: Value(productId)));
    } else {
      await (_db.update(_db.ratings)..where((r) => r.id.equals(existing.id))).write(values);
    }
    await setStores(productId, storeIds);
    // Remember for the next rating: in a store you usually scan several
    // products in a row.
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(SettingsCompanion.insert(key: _lastStoresKey, value: storeIds.join(',')));
  });

  static const _lastStoresKey = 'last_store_ids';

  /// Stores of the most recently saved rating (only those that still exist).
  Future<Set<int>> lastUsedStoreIds() async {
    final row = await (_db.select(_db.settings)..where((s) => s.key.equals(_lastStoresKey))).getSingleOrNull();
    final ids = (row?.value ?? '').split(',').map(int.tryParse).whereType<int>().toSet();
    if (ids.isEmpty) return const {};
    final existing = await (_db.select(_db.stores)..where((s) => s.id.isIn(ids))).get();
    return existing.map((s) => s.id).toSet();
  }

  Future<void> setStores(int productId, Set<int> storeIds) => _db.transaction(() async {
    await (_db.delete(_db.productStores)..where((ps) => ps.productId.equals(productId))).go();
    await _db.batch(
      (b) => b.insertAll(_db.productStores, [
        for (final id in storeIds) ProductStoresCompanion.insert(productId: productId, storeId: id),
      ]),
    );
  });

  /// User corrections to name, brand, quantity and category.
  Future<void> updateProduct(
    int productId, {
    required String name,
    String? brand,
    String? quantity,
    required ProductCategory category,
  }) => (_db.update(_db.products)..where((p) => p.id.equals(productId))).write(
    ProductsCompanion(
      name: Value(name),
      brand: Value(brand),
      quantity: Value(quantity),
      category: Value(category.name),
    ),
  );

  Future<void> setCategory(int productId, ProductCategory category) => (_db.update(
    _db.products,
  )..where((p) => p.id.equals(productId))).write(ProductsCompanion(category: Value(category.name)));
}
