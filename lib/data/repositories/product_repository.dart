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
    yield* _db.tableUpdates(TableUpdateQuery.onAllTables([_db.products, _db.ratings, _db.stores]));
  }

  /// Alle Produkte mit Bewertungen, zuletzt aktive zuerst.
  Stream<List<ProductSummary>> watchSummaries() => _changes.asyncMap((_) => loadSummaries());

  Stream<ProductSummary?> watchProduct(int id) => _changes.asyncMap((_) => loadProduct(id));

  Future<List<ProductSummary>> loadSummaries() async {
    final products = await _db.select(_db.products).get();
    final ratingsByProduct = await _ratingsByProduct();
    final summaries = [
      for (final p in products) ProductSummary(product: p, ratings: ratingsByProduct[p.id] ?? const []),
    ]..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    return summaries;
  }

  Future<ProductSummary?> loadProduct(int id) async {
    final product = await (_db.select(_db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
    if (product == null) return null;
    final ratings = await _ratingsByProduct(productId: id);
    return ProductSummary(product: product, ratings: ratings[id] ?? const []);
  }

  Future<ProductSummary?> findByBarcode(String barcode) async {
    final product = await (_db.select(_db.products)..where((p) => p.barcode.equals(barcode))).getSingleOrNull();
    return product == null ? null : loadProduct(product.id);
  }

  Future<Map<int, List<RatingWithStore>>> _ratingsByProduct({int? productId}) async {
    final query = _db.select(_db.ratings).join([
      leftOuterJoin(_db.stores, _db.stores.id.equalsExp(_db.ratings.storeId)),
    ]);
    if (productId != null) query.where(_db.ratings.productId.equals(productId));
    query.orderBy([OrderingTerm.desc(_db.ratings.ratedAt), OrderingTerm.desc(_db.ratings.id)]);

    final result = <int, List<RatingWithStore>>{};
    for (final row in await query.get()) {
      final rating = row.readTable(_db.ratings);
      result.putIfAbsent(rating.productId, () => []).add(RatingWithStore(rating, row.readTableOrNull(_db.stores)));
    }
    return result;
  }

  /// Legt das Produkt an oder aktualisiert die OFF-Daten eines vorhandenen.
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

  Future<int> addRating({
    required int productId,
    required int score,
    required bool wouldBuyAgain,
    int? storeId,
    int? priceCents,
    String? note,
    double? latitude,
    double? longitude,
  }) => _db
      .into(_db.ratings)
      .insert(
        RatingsCompanion.insert(
          productId: productId,
          score: score,
          wouldBuyAgain: wouldBuyAgain,
          storeId: Value(storeId),
          priceCents: Value(priceCents),
          note: Value(note),
          latitude: Value(latitude),
          longitude: Value(longitude),
        ),
      );

  Future<void> deleteRating(int ratingId) => (_db.delete(_db.ratings)..where((r) => r.id.equals(ratingId))).go();

  /// Eigene Korrekturen an Name, Marke, Menge und Kategorie.
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
