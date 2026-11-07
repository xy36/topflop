import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup/backup_service.dart';
import 'db/database.dart';
import 'remote/open_food_facts_client.dart';
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

final productSummariesProvider = StreamProvider<List<ProductSummary>>(
  (ref) => ref.watch(productRepositoryProvider).watchSummaries(),
);

final productProvider = StreamProvider.family<ProductSummary?, int>(
  (ref, id) => ref.watch(productRepositoryProvider).watchProduct(id),
);

final storeSummariesProvider = StreamProvider<List<StoreSummary>>(
  (ref) => ref.watch(storeRepositoryProvider).watchSummaries(),
);
