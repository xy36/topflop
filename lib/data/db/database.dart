import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Ein Produkt. Daten stammen von Open Food Facts oder wurden selbst angelegt.
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

/// Ein Laden im Sinne einer Kette („Lidl“). Produkte werden der Kette
/// zugeordnet, weil das Sortiment fast überall gleich ist.
class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Die (einzige) Bewertung eines Produkts.
class Ratings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().unique().references(Products, #id, onDelete: KeyAction.cascade)();
  // ignore: recursive_getters
  IntColumn get score => integer().check(score.isBetweenValues(1, 10))();
  BoolColumn get wouldBuyAgain => boolean()();
  IntColumn get priceCents => integer().nullable()();
  TextColumn get note => text().nullable()();

  /// Zeitpunkt der letzten Änderung.
  DateTimeColumn get ratedAt => dateTime().withDefault(currentDateAndTime)();
}

/// In welchen Läden es ein Produkt gibt (beliebig viele).
class ProductStores extends Table {
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get storeId => integer().references(Stores, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {productId, storeId};
}

/// Kleine Schlüssel-Wert-Ablage für App-Einstellungen (z. B. letzter Export).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Products, Stores, Ratings, ProductStores, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: fileName));

  /// Dateiname ohne Endung; liegt im App-Dokumentenordner und wird so vom
  /// System-Backup (Android Auto Backup / iCloud) erfasst.
  static const fileName = 'topflop';

  /// 1: mehrere Bewertungen pro Produkt, Laden an der Bewertung.
  /// 2: eine Bewertung pro Produkt, Läden am Produkt (mehrere möglich).
  /// 3: Läden sind Ketten mit Filialen; kein Standort mehr an Bewertungen.
  /// 4: keine Standorte mehr; Läden sind nur noch Ketten mit Namen.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(productStores);
        // Alle Läden aus dem bisherigen Verlauf übernehmen.
        await customStatement(
          'INSERT OR IGNORE INTO product_stores (product_id, store_id) '
          'SELECT product_id, store_id FROM ratings WHERE store_id IS NOT NULL',
        );
        // Pro Produkt nur die neueste Bewertung behalten.
        await customStatement(
          'DELETE FROM ratings WHERE EXISTS ('
          'SELECT 1 FROM ratings newer WHERE newer.product_id = ratings.product_id '
          'AND (newer.rated_at > ratings.rated_at OR (newer.rated_at = ratings.rated_at AND newer.id > ratings.id)))',
        );
        // Tabelle neu aufbauen: ohne store_id, mit eindeutiger product_id.
        await m.alterTable(TableMigration(ratings));
      }
      if (from < 3) {
        // Läden mit gleichem Namen zu einer Kette zusammenführen.
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
        // Spalten entfernen: Adresse/Koordinaten am Laden, Standort an Bewertungen.
        await m.alterTable(TableMigration(stores));
        await m.alterTable(TableMigration(ratings));
      }
      if (from == 3) {
        // Filialen mit Koordinaten werden nicht mehr gebraucht.
        await customStatement('DROP TABLE IF EXISTS store_locations');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
