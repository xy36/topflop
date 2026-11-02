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

/// Geschäfte aus OpenStreetMap in der Nähe, die noch nicht angelegt sind.
final nearbySuggestionsProvider = FutureProvider<List<NearbySuggestion>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  if (position == null) return const [];
  final known = await ref.watch(storeSummariesProvider.future);
  final knownNames = known.map((s) => s.store.name.toLowerCase()).toSet();
  try {
    final shops = await ref.watch(overpassProvider).shopsAround(position.latitude, position.longitude);
    final suggestions = [
      for (final shop in shops)
        if (!knownNames.contains(shop.name.toLowerCase()))
          NearbySuggestion(shop, position.distanceTo(shop.latitude, shop.longitude)),
    ]..sort((a, b) => a.distance.compareTo(b.distance));
    return suggestions.take(3).toList();
  } catch (_) {
    return const [];
  }
});

class NearbySuggestion {
  const NearbySuggestion(this.shop, this.distance);

  final NearbyShop shop;
  final double distance;
}
