import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A product. Data comes from Open Food Facts or was entered manually.
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get quantity => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get nutriScore => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A store in the sense of a chain ("Lidl"). Products are assigned to the
/// chain because the range is almost the same everywhere.
class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// The (only) rating of a product.
class Ratings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().unique().references(Products, #id, onDelete: KeyAction.cascade)();
  // ignore: recursive_getters
  IntColumn get score => integer().check(score.isBetweenValues(1, 10))();
  BoolColumn get wouldBuyAgain => boolean()();
  IntColumn get priceCents => integer().nullable()();
  TextColumn get note => text().nullable()();

  /// Time of the last change.
  DateTimeColumn get ratedAt => dateTime().withDefault(currentDateAndTime)();
}

/// The stores that carry a product (any number).
class ProductStores extends Table {
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get storeId => integer().references(Stores, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {productId, storeId};
}

/// Small key-value store for app settings (e.g. last export).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Products, Stores, Ratings, ProductStores, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: fileName));

  /// File name without extension; lives in the app documents folder and is
  /// therefore included in the system backup (Android Auto Backup / iCloud).
  static const fileName = 'topflop';

  /// 1: several ratings per product, store on the rating.
  /// 2: one rating per product, stores on the product (several possible).
  /// 3: stores are chains with branches; no location on ratings anymore.
  /// 4: no locations anymore; stores are just chains with a name.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(productStores);
        // Take over all stores from the existing history.
        await customStatement(
          'INSERT OR IGNORE INTO product_stores (product_id, store_id) '
          'SELECT product_id, store_id FROM ratings WHERE store_id IS NOT NULL',
        );
        // Keep only the newest rating per product.
        await customStatement(
          'DELETE FROM ratings WHERE EXISTS ('
          'SELECT 1 FROM ratings newer WHERE newer.product_id = ratings.product_id '
          'AND (newer.rated_at > ratings.rated_at OR (newer.rated_at = ratings.rated_at AND newer.id > ratings.id)))',
        );
        // Rebuild the table: without store_id, with a unique product_id.
        await m.alterTable(TableMigration(ratings));
      }
      if (from < 3) {
        // Merge stores with the same name into one chain.
        await customStatement(
          'CREATE TEMP TABLE store_merge AS SELECT s.id AS old_id, '
          '(SELECT MIN(s2.id) FROM stores s2 WHERE lower(trim(s2.name)) = lower(trim(s.name))) AS new_id '
          'FROM stores s',
        );
        await customStatement(
          'INSERT OR IGNORE INTO product_stores (product_id, store_id) '
          'SELECT ps.product_id, m.new_id FROM product_stores ps JOIN store_merge m ON m.old_id = ps.store_id '
          'WHERE m.old_id != m.new_id',
        );
        await customStatement(
          'DELETE FROM product_stores WHERE store_id IN (SELECT old_id FROM store_merge WHERE old_id != new_id)',
        );
        await customStatement('DELETE FROM stores WHERE id IN (SELECT old_id FROM store_merge WHERE old_id != new_id)');
        await customStatement('DROP TABLE store_merge');
        // Drop columns: address/coordinates on stores, location on ratings.
        await m.alterTable(TableMigration(stores));
        await m.alterTable(TableMigration(ratings));
      }
      if (from == 3) {
        // Branches with coordinates are no longer needed.
        await customStatement('DROP TABLE IF EXISTS store_locations');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
