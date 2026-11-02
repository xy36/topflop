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

class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Ein Eintrag im Verlauf: ein Kauf mit Bewertung.
class Ratings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get storeId => integer().nullable().references(Stores, #id, onDelete: KeyAction.setNull)();
  // ignore: recursive_getters
  IntColumn get score => integer().check(score.isBetweenValues(1, 10))();
  BoolColumn get wouldBuyAgain => boolean()();
  IntColumn get priceCents => integer().nullable()();
  TextColumn get note => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get ratedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Kleine Schlüssel-Wert-Ablage für App-Einstellungen (z. B. letzter Export).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Products, Stores, Ratings, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: fileName));

  /// Dateiname ohne Endung; liegt im App-Dokumentenordner und wird so vom
  /// System-Backup (Android Auto Backup / iCloud) erfasst.
  static const fileName = 'topflop';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
