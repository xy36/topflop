import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nochmal/core/domain/product_category.dart';
import 'package:nochmal/core/domain/score.dart';
import 'package:nochmal/core/widgets/common.dart';
import 'package:nochmal/data/backup/backup_service.dart';
import 'package:nochmal/data/db/database.dart';
import 'package:nochmal/data/remote/open_food_facts_client.dart';
import 'package:nochmal/data/repositories/product_repository.dart';
import 'package:nochmal/data/repositories/store_repository.dart';

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
          expect(request.headers['User-Agent'], contains('Nochmal'));
          return http.Response.bytes(
            utf8.encode(jsonEncode({
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
            })),
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

    Future<int> salami() => products.upsertFromOff(const OffProduct(
          barcode: '4012345678901',
          name: 'Salami Milano',
          brand: 'Hofgut Lindner',
          category: ProductCategory.meat,
        ));

    test('Verlauf, Durchschnitt und letztes Urteil', () async {
      final id = await salami();
      final rewe = await stores.addStore(name: 'Rewe Lindenstraße', latitude: 52.0, longitude: 8.0);
      await products.addRating(productId: id, score: 8, wouldBuyAgain: false, storeId: rewe);
      await Future<void>.delayed(const Duration(seconds: 1));
      await products.addRating(productId: id, score: 9, wouldBuyAgain: true, storeId: rewe, priceCents: 349);

      final summary = (await products.findByBarcode('4012345678901'))!;
      expect(summary.ratingCount, 2);
      expect(summary.averageScore, 8.5);
      expect(summary.wouldBuyAgain, isTrue);
      expect(summary.lastStoreName, 'Rewe Lindenstraße');
      expect(summary.stores.map((s) => s.name), ['Rewe Lindenstraße']);

      final storeSummaries = await stores.loadSummaries();
      expect(storeSummaries.single.ratedCount, 1);
    });

    test('erneuter Scan aktualisiert statt zu duplizieren', () async {
      final a = await salami();
      final b = await salami();
      expect(a, b);
      expect(await products.loadSummaries(), hasLength(1));
    });

    test('Bewertung außerhalb 1–10 wird abgelehnt', () async {
      final id = await salami();
      expect(products.addRating(productId: id, score: 11, wouldBuyAgain: true), throwsA(anything));
    });

    test('Produkt löschen entfernt seine Bewertungen', () async {
      final id = await salami();
      await products.addRating(productId: id, score: 7, wouldBuyAgain: true);
      await products.deleteProduct(id);
      expect(await db.select(db.ratings).get(), isEmpty);
    });

    test('Backup: Export und Import ergeben dieselben Daten', () async {
      final id = await salami();
      final store = await stores.addStore(name: 'Edeka Am Markt');
      await products.setFavorite(id, true);
      await products.addRating(productId: id, score: 9, wouldBuyAgain: true, storeId: store, note: 'Schön mild');

      final json = jsonEncode({
        'app': 'nochmal',
        'version': BackupService.formatVersion,
        'products': [for (final p in await db.select(db.products).get()) p.toJson()],
        'stores': [for (final s in await db.select(db.stores).get()) s.toJson()],
        'ratings': [for (final r in await db.select(db.ratings).get()) r.toJson()],
      });

      final target = AppDatabase(NativeDatabase.memory());
      addTearDown(target.close);
      await BackupService(target).importJson(json);

      final restored = (await ProductRepository(target).findByBarcode('4012345678901'))!;
      expect(restored.product.isFavorite, isTrue);
      expect(restored.ratings.single.rating.note, 'Schön mild');
      expect(restored.ratings.single.store?.name, 'Edeka Am Markt');
    });

    test('Backup: fremde Dateien werden abgelehnt', () async {
      expect(BackupService(db).importJson('{"app":"other"}'), throwsFormatException);
      expect(BackupService(db).importJson('kein json'), throwsFormatException);
    });
  });
}
