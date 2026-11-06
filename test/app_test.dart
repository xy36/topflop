import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:topflop/core/domain/product_category.dart';
import 'package:topflop/core/domain/score.dart';
import 'package:topflop/core/widgets/common.dart';
import 'package:topflop/data/backup/backup_service.dart';
import 'package:topflop/data/db/database.dart';
import 'package:topflop/data/remote/open_food_facts_client.dart';
import 'package:topflop/data/repositories/product_repository.dart';
import 'package:topflop/data/repositories/store_repository.dart';
import 'package:topflop/features/home/product_filter.dart';

void main() {
  // Der Backup-Test öffnet absichtlich zwei In-Memory-Datenbanken.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Domain', () {
    test('Emoji-Skala deckt 1–10 ab und klemmt Randwerte', () {
      expect(Score.emoji(1), '🤮');
      expect(Score.emoji(10), '🤩');
      expect(Score.emoji(0), Score.emoji(1));
      expect(Score.emoji(11), Score.emoji(10));
    });

    test('OFF-Kategorien: spezifischster Tag gewinnt', () {
      expect(ProductCategory.fromOffTags(['en:meats', 'en:sausages', 'en:salamis']), ProductCategory.meat);
      expect(ProductCategory.fromOffTags(['en:dairies', 'en:fermented-foods', 'en:cheeses']), ProductCategory.cheese);
      expect(ProductCategory.fromOffTags(['en:something-else']), ProductCategory.other);
    });

    test('Preise parsen', () {
      expect(parsePriceCents('3,49'), 349);
      expect(parsePriceCents('3.49 €'), 349);
      expect(parsePriceCents(''), isNull);
      expect(parsePriceCents('abc'), isNull);
    });
  });

  group('Open Food Facts', () {
    test('liest Produktdaten und lokalisierten Namen', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((request) async {
          expect(request.url.host, 'world.openfoodfacts.org');
          expect(request.headers['User-Agent'], contains('TopFlop'));
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'status': 1,
                'product': {
                  'product_name': 'Salami',
                  'product_name_de': 'Salami Milano',
                  'brands': 'Hofgut Lindner, Andere',
                  'quantity': '200 g',
                  'nutriscore_grade': 'd',
                  'image_front_url': 'https://images.example/salami.jpg',
                  'categories_tags': ['en:meats', 'en:salamis'],
                },
              }),
            ),
            200,
          );
        }),
      );

      final p = await client.lookup('4012345678901');
      expect(p!.name, 'Salami Milano');
      expect(p.brand, 'Hofgut Lindner');
      expect(p.nutriScore, 'D');
      expect(p.category, ProductCategory.meat);
    });

    test('unbekannter Barcode ergibt null (alle Datenbanken gefragt)', () async {
      final hosts = <String>[];
      final client = OpenFoodFactsClient(
        httpClient: MockClient((request) async {
          hosts.add(request.url.host);
          return http.Response('{"status":0}', 200);
        }),
      );
      expect(await client.lookup('123'), isNull);
      expect(hosts, hasLength(3));
    });

    test('Netzwerkfehler wird als OffLookupException gemeldet', () async {
      final client = OpenFoodFactsClient(httpClient: MockClient((_) async => throw http.ClientException('offline')));
      expect(client.lookup('123'), throwsA(isA<OffLookupException>()));
    });

    test('Händlertexte als Produktname werden übersprungen', () {
      const shopText = 'EDEKA Hayunga Getränke Coca-Cola Zero  Mehrweg Pet 1L X11 l (1,29 € / 1 l) zzgl. Pfand 0,15 €';
      expect(OpenFoodFactsClient.pickName([shopText, 'Coca-Cola Zero', null]), 'Coca-Cola Zero');
      expect(OpenFoodFactsClient.pickName(['', '  Salami   Milano ']), 'Salami Milano');
      // Gibt es nur den unsauberen Namen, wird er trotzdem genommen.
      expect(OpenFoodFactsClient.pickName([shopText]), startsWith('EDEKA'));
      expect(OpenFoodFactsClient.pickName([null, '']), isNull);
    });
  });

  group('Datenbank', () {
    late AppDatabase db;
    late ProductRepository products;
    late StoreRepository stores;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      products = ProductRepository(db);
      stores = StoreRepository(db, products);
    });
    tearDown(() => db.close());

    Future<int> salami() => products.upsertFromOff(
      const OffProduct(
        barcode: '4012345678901',
        name: 'Salami Milano',
        brand: 'Hofgut Lindner',
        category: ProductCategory.meat,
      ),
    );

    test('Eine Bewertung pro Produkt: Speichern überschreibt, Läden mehrfach', () async {
      final id = await salami();
      final rewe = await stores.addStore(name: 'Rewe');
      final edeka = await stores.addStore(name: 'Edeka');

      await products.saveRating(productId: id, score: 6, wouldBuyAgain: false, storeIds: {rewe}, note: 'naja');
      await products.saveRating(productId: id, score: 9, wouldBuyAgain: true, storeIds: {rewe, edeka}, priceCents: 349);

      expect(await db.select(db.ratings).get(), hasLength(1));
      final summary = (await products.findByBarcode('4012345678901'))!;
      expect(summary.score, 9);
      expect(summary.wouldBuyAgain, isTrue);
      expect(summary.rating!.priceCents, 349);
      expect(summary.rating!.note, isNull);
      expect(summary.stores.map((s) => s.name), ['Edeka', 'Rewe']);
      expect(summary.storeName, 'Edeka');

      final perStore = await stores.loadSummaries();
      expect(perStore.map((s) => s.ratedCount), [1, 1]);

      await products.saveRating(productId: id, score: 9, wouldBuyAgain: true, storeIds: {});
      expect((await products.loadProduct(id))!.stores, isEmpty);
    });

    test('erneuter Scan aktualisiert statt zu duplizieren', () async {
      final a = await salami();
      final b = await salami();
      expect(a, b);
      expect(await products.loadSummaries(), hasLength(1));
    });

    test('Bewertung außerhalb 1–10 wird abgelehnt', () async {
      final id = await salami();
      expect(products.saveRating(productId: id, score: 11, wouldBuyAgain: true, storeIds: {}), throwsA(anything));
    });

    test('Produkt löschen entfernt Bewertung und Ladenzuordnung', () async {
      final id = await salami();
      final store = await stores.addStore(name: 'Aldi');
      await products.saveRating(productId: id, score: 7, wouldBuyAgain: true, storeIds: {store});
      await products.deleteProduct(id);
      expect(await db.select(db.ratings).get(), isEmpty);
      expect(await db.select(db.productStores).get(), isEmpty);
    });

    test('Laden umbenennen und löschen – Bewertung bleibt', () async {
      final id = await salami();
      final store = await stores.addStore(name: 'Aldi', latitude: 52, longitude: 8);
      await products.saveRating(productId: id, score: 7, wouldBuyAgain: true, storeIds: {store});

      await stores.renameStore(store, 'Aldi Süd');
      expect((await products.loadProduct(id))!.storeName, 'Aldi Süd');
      expect(await stores.allLocations(), hasLength(1));

      await stores.deleteStore(store);
      final summary = (await products.loadProduct(id))!;
      expect(summary.score, 7);
      expect(summary.stores, isEmpty);
      expect(await stores.allLocations(), isEmpty);
    });

    test('Ketten: gleiche Kette wird erkannt, Filialen kommen dazu', () async {
      expect(StoreRepository.chainKey('ALDI SÜD'), 'aldi');
      expect(StoreRepository.chainKey('  Lidl  Ringstraße'), 'lidl');
      expect(StoreRepository.chainKey('dm-drogerie markt'), 'dmdrogerie');

      final lidl = await stores.addStore(name: 'Lidl', latitude: 52.0, longitude: 8.0, address: 'Hauptstraße 1');
      final again = await stores.addStore(name: 'lidl ringstraße', latitude: 52.1, longitude: 8.1);
      final aldi = await stores.addStore(name: 'ALDI SÜD');
      expect(again, lidl);
      expect(await stores.findOrCreateChain('Aldi'), aldi);

      final summaries = await stores.loadSummaries();
      final lidlSummary = summaries.firstWhere((s) => s.store.id == lidl);
      expect(lidlSummary.store.name, 'Lidl');
      expect(lidlSummary.locations, hasLength(2));
      final nearest = lidlSummary.nearest((lat, lon) => (lat - 52.09).abs() * 100000)!;
      expect(nearest.$1.latitude, 52.1);

      await stores.deleteLocation(nearest.$1.id);
      expect((await stores.allLocations()).map((l) => l.address), ['Hauptstraße 1']);
    });

    test('Backup: Export und Import ergeben dieselben Daten', () async {
      final id = await salami();
      final a = await stores.addStore(name: 'Edeka Am Markt', latitude: 52, longitude: 8, address: 'Am Markt 1');
      final b = await stores.addStore(name: 'Rewe');
      await products.setFavorite(id, true);
      await products.saveRating(productId: id, score: 9, wouldBuyAgain: true, storeIds: {a, b}, note: 'Schön mild');

      final json = jsonEncode({
        'app': 'topflop',
        'version': BackupService.formatVersion,
        'products': [for (final p in await db.select(db.products).get()) p.toJson()],
        'stores': [for (final s in await db.select(db.stores).get()) s.toJson()],
        'storeLocations': [for (final l in await db.select(db.storeLocations).get()) l.toJson()],
        'ratings': [for (final r in await db.select(db.ratings).get()) r.toJson()],
        'productStores': [for (final ps in await db.select(db.productStores).get()) ps.toJson()],
      });

      final target = AppDatabase(NativeDatabase.memory());
      addTearDown(target.close);
      await BackupService(target).importJson(json);

      final restored = (await ProductRepository(target).findByBarcode('4012345678901'))!;
      expect(restored.product.isFavorite, isTrue);
      expect(restored.rating!.note, 'Schön mild');
      expect(restored.stores.map((s) => s.name), ['Edeka Am Markt', 'Rewe']);
      expect((await target.select(target.storeLocations).get()).single.address, 'Am Markt 1');
    });

    test('Backup: Sicherung Version 2 – gleichnamige Läden werden zu einer Kette', () async {
      final json = jsonEncode({
        'app': 'topflop',
        'version': 2,
        'products': [
          {'id': 1, 'name': 'Cola', 'category': 'drink', 'isFavorite': false, 'createdAt': 1000},
        ],
        'stores': [
          {'id': 1, 'name': 'Lidl', 'latitude': 52.0, 'longitude': 8.0, 'address': 'A', 'createdAt': 1000},
          {'id': 2, 'name': 'lidl', 'latitude': 53.0, 'longitude': 9.0, 'createdAt': 1000},
          {'id': 3, 'name': 'Aldi', 'createdAt': 1000},
        ],
        'ratings': [
          {'id': 1, 'productId': 1, 'score': 8, 'wouldBuyAgain': true, 'latitude': 1.0, 'ratedAt': 3000},
        ],
        'productStores': [
          {'productId': 1, 'storeId': 1},
          {'productId': 1, 'storeId': 2},
          {'productId': 1, 'storeId': 3},
        ],
      });
      await BackupService(db).importJson(json);

      expect((await stores.allStores()).map((s) => s.name), ['Aldi', 'Lidl']);
      expect(await stores.allLocations(), hasLength(2));
      expect((await products.loadProduct(1))!.stores.map((s) => s.name), ['Aldi', 'Lidl']);
    });

    test('Backup: alte Sicherung (Version 1) mit mehreren Bewertungen wird übernommen', () async {
      final json = jsonEncode({
        'app': 'topflop',
        'version': 1,
        'products': [
          {'id': 1, 'barcode': '1', 'name': 'Cola', 'category': 'drink', 'isFavorite': false, 'createdAt': 1000},
        ],
        'stores': [
          {'id': 1, 'name': 'Aldi', 'createdAt': 1000},
          {'id': 2, 'name': 'Lidl', 'createdAt': 1000},
        ],
        'ratings': [
          {'id': 1, 'productId': 1, 'storeId': 1, 'score': 5, 'wouldBuyAgain': false, 'ratedAt': 2000},
          {'id': 2, 'productId': 1, 'storeId': 2, 'score': 8, 'wouldBuyAgain': true, 'ratedAt': 3000},
        ],
      });
      await BackupService(db).importJson(json);

      final cola = (await products.loadProduct(1))!;
      expect(cola.score, 8);
      expect(cola.stores.map((s) => s.name), ['Aldi', 'Lidl']);
    });

    test('Backup: fremde Dateien werden abgelehnt', () async {
      expect(BackupService(db).importJson('{"app":"other"}'), throwsFormatException);
      expect(BackupService(db).importJson('kein json'), throwsFormatException);
    });

    test('Filter nach Bewertung, Laden, Kategorie, Urteil und Sortierung', () async {
      final salamiId = await salami();
      final kaeseId = await products.createManual(name: 'Bergkäse', category: ProductCategory.cheese);
      final colaId = await products.createManual(name: 'Cola', category: ProductCategory.drink);
      final rewe = await stores.addStore(name: 'Rewe');
      final edeka = await stores.addStore(name: 'Edeka');
      await products.saveRating(productId: salamiId, score: 9, wouldBuyAgain: true, storeIds: {rewe});
      await products.saveRating(productId: kaeseId, score: 4, wouldBuyAgain: false, storeIds: {edeka, rewe});
      await products.setFavorite(kaeseId, true);
      // Cola bleibt unbewertet.

      final all = await products.loadSummaries();
      List<String> names(ProductFilter f) => f.apply(all).map((s) => s.product.name).toList();

      expect(names(const ProductFilter(minScore: 8)), ['Salami Milano']);
      expect(names(ProductFilter(storeIds: {edeka})), ['Bergkäse']);
      expect(names(ProductFilter(storeIds: {rewe}, sort: ProductSort.name)), ['Bergkäse', 'Salami Milano']);
      expect(names(const ProductFilter(categories: {ProductCategory.drink})), ['Cola']);
      expect(names(const ProductFilter(buyAgain: false)), ['Bergkäse']);
      expect(names(const ProductFilter(favoritesOnly: true)), ['Bergkäse']);
      expect(names(const ProductFilter(sort: ProductSort.bestRated)), ['Salami Milano', 'Bergkäse', 'Cola']);
      expect(names(const ProductFilter(sort: ProductSort.worstRated)), ['Bergkäse', 'Salami Milano', 'Cola']);
      expect(const ProductFilter(minScore: 3, favoritesOnly: true).activeCount, 2);
      expect(const ProductFilter(minScore: 3, sort: ProductSort.name).cleared().isActive, isFalse);

      await products.setCategory(colaId, ProductCategory.dairy);
      expect((await products.loadProduct(colaId))!.product.category, ProductCategory.dairy.name);
    });
  });

  test('Migration von Schema 1: neueste Bewertung bleibt, alle Läden werden übernommen', () async {
    // Datenbank im Stand von Version 1 (mehrere Bewertungen, Laden an der Bewertung).
    final legacy = NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
          CREATE TABLE products (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, barcode TEXT NULL UNIQUE,
            name TEXT NOT NULL, brand TEXT NULL, quantity TEXT NULL, image_url TEXT NULL, nutri_score TEXT NULL,
            category TEXT NOT NULL DEFAULT 'other', is_favorite INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE stores (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
            address TEXT NULL, latitude REAL NULL, longitude REAL NULL,
            created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE ratings (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL REFERENCES products (id) ON DELETE CASCADE,
            store_id INTEGER NULL REFERENCES stores (id) ON DELETE SET NULL,
            score INTEGER NOT NULL CHECK (score BETWEEN 1 AND 10), would_buy_again INTEGER NOT NULL,
            price_cents INTEGER NULL, note TEXT NULL, latitude REAL NULL, longitude REAL NULL,
            rated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE settings ("key" TEXT NOT NULL, value TEXT NOT NULL, PRIMARY KEY ("key"));
          INSERT INTO products (id, name) VALUES (1, 'Salami'), (2, 'Käse');
          INSERT INTO stores (id, name) VALUES (1, 'Aldi'), (2, 'Lidl');
          INSERT INTO ratings (product_id, store_id, score, would_buy_again, note, rated_at) VALUES
            (1, 1, 5, 0, 'alt', 100), (1, 2, 9, 1, 'neu', 200), (1, NULL, 7, 1, 'mittel', 150),
            (2, NULL, 4, 0, NULL, 100);
          PRAGMA user_version = 1;
        ''');
      },
    );
    final db = AppDatabase(legacy);
    addTearDown(db.close);
    final repo = ProductRepository(db);

    final salami = (await repo.loadProduct(1))!;
    expect([salami.score, salami.rating!.note], [9, 'neu']);
    expect(salami.stores.map((s) => s.name), ['Aldi', 'Lidl']);
    final kaese = (await repo.loadProduct(2))!;
    expect([kaese.score, kaese.stores], [4, isEmpty]);
    expect(await db.select(db.ratings).get(), hasLength(2));

    // Eindeutigkeit gilt nach der Migration.
    expect(
      db.into(db.ratings).insert(RatingsCompanion.insert(productId: 1, score: 3, wouldBuyAgain: false)),
      throwsA(anything),
    );
  });

  test('Migration von Schema 2: Läden werden Ketten mit Filialen, gleiche Namen zusammengeführt', () async {
    final legacy = NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
          CREATE TABLE products (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, barcode TEXT NULL UNIQUE,
            name TEXT NOT NULL, brand TEXT NULL, quantity TEXT NULL, image_url TEXT NULL, nutri_score TEXT NULL,
            category TEXT NOT NULL DEFAULT 'other', is_favorite INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE stores (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
            address TEXT NULL, latitude REAL NULL, longitude REAL NULL,
            created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE ratings (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL UNIQUE REFERENCES products (id) ON DELETE CASCADE,
            score INTEGER NOT NULL CHECK (score BETWEEN 1 AND 10), would_buy_again INTEGER NOT NULL,
            price_cents INTEGER NULL, note TEXT NULL, latitude REAL NULL, longitude REAL NULL,
            rated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE product_stores (product_id INTEGER NOT NULL REFERENCES products (id) ON DELETE CASCADE,
            store_id INTEGER NOT NULL REFERENCES stores (id) ON DELETE CASCADE, PRIMARY KEY (product_id, store_id));
          CREATE TABLE settings ("key" TEXT NOT NULL, value TEXT NOT NULL, PRIMARY KEY ("key"));
          INSERT INTO products (id, name) VALUES (1, 'Cola'), (2, 'Chips');
          INSERT INTO stores (id, name, address, latitude, longitude) VALUES
            (1, 'Lidl', 'Hauptstraße', 52.0, 8.0), (2, 'Lidl ', NULL, 53.0, 9.0), (3, 'Aldi', NULL, NULL, NULL);
          INSERT INTO ratings (product_id, score, would_buy_again, latitude, longitude) VALUES (1, 8, 1, 52.0, 8.0);
          INSERT INTO product_stores VALUES (1, 1), (1, 2), (2, 2), (2, 3);
          PRAGMA user_version = 2;
        ''');
      },
    );
    final db = AppDatabase(legacy);
    addTearDown(db.close);
    final repo = ProductRepository(db);

    expect((await db.select(db.stores).get()).map((s) => s.name), ['Lidl', 'Aldi']);
    final locations = await db.select(db.storeLocations).get();
    expect(locations.map((l) => (l.storeId, l.address)), [(1, 'Hauptstraße'), (1, null)]);
    expect((await repo.loadProduct(1))!.stores.map((s) => s.name), ['Lidl']);
    expect((await repo.loadProduct(2))!.stores.map((s) => s.name), ['Aldi', 'Lidl']);
    expect((await repo.loadProduct(1))!.score, 8);
  });
}
