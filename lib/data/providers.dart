import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup/backup_service.dart';
import 'db/database.dart';
import 'location/location_service.dart';
import 'remote/open_food_facts_client.dart';
import 'remote/overpass_client.dart';
import 'repositories/models.dart';
import 'repositories/product_repository.dart';
import 'repositories/store_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final productRepositoryProvider = Provider((ref) => ProductRepository(ref.watch(databaseProvider)));
final storeRepositoryProvider = Provider(
  (ref) => StoreRepository(ref.watch(databaseProvider), ref.watch(productRepositoryProvider)),
);
final backupServiceProvider = Provider((ref) => BackupService(ref.watch(databaseProvider)));

final openFoodFactsProvider = Provider((ref) => OpenFoodFactsClient());
final overpassProvider = Provider((ref) => OverpassClient());
final locationServiceProvider = Provider((ref) => LocationService());

final productSummariesProvider = StreamProvider<List<ProductSummary>>(
  (ref) => ref.watch(productRepositoryProvider).watchSummaries(),
);

final productProvider = StreamProvider.family<ProductSummary?, int>(
  (ref, id) => ref.watch(productRepositoryProvider).watchProduct(id),
);

final storeSummariesProvider = StreamProvider<List<StoreSummary>>(
  (ref) => ref.watch(storeRepositoryProvider).watchSummaries(),
);

/// Aktueller Standort; wird bei Bedarf über `ref.invalidate` neu ermittelt.
final currentPositionProvider = FutureProvider<LatLon?>((ref) => ref.watch(locationServiceProvider).currentPosition());

/// Filialen aus OpenStreetMap in der Nähe, die noch nicht gespeichert sind –
/// auch neue Filialen bekannter Ketten (z. B. ein anderer Lidl).
final nearbySuggestionsProvider = FutureProvider<List<NearbySuggestion>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  if (position == null) return const [];
  final known = await ref.watch(storeSummariesProvider.future);
  final knownLocations = [for (final s in known) ...s.locations];
  try {
    final shops = await ref.watch(overpassProvider).shopsAround(position.latitude, position.longitude);
    final suggestions = [
      for (final shop in shops)
        // Schon gespeichert, wenn eine Filiale fast am selben Ort liegt.
        if (!knownLocations.any((l) => LatLon(l.latitude, l.longitude).distanceTo(shop.latitude, shop.longitude) < 75))
          NearbySuggestion(
            shop,
            position.distanceTo(shop.latitude, shop.longitude),
            chain: known
                .map((s) => s.store)
                .where((s) => StoreRepository.chainKey(s.name) == StoreRepository.chainKey(shop.name))
                .firstOrNull,
          ),
    ]..sort((a, b) => a.distance.compareTo(b.distance));
    return suggestions.take(3).toList();
  } catch (_) {
    return const [];
  }
});

class NearbySuggestion {
  const NearbySuggestion(this.shop, this.distance, {this.chain});

  final NearbyShop shop;
  final double distance;

  /// Bereits bekannte Kette, zu der diese Filiale gehören würde.
  final Store? chain;
}
