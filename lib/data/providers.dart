import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart' show ThemeMode;
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

/// Hell, dunkel oder wie das System; gespeichert in der Einstellungstabelle.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.settings)..where((s) => s.key.equals(_key))).getSingleOrNull();
    final stored = ThemeMode.values.where((m) => m.name == row?.value).firstOrNull;
    if (stored != null) state = stored;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final db = ref.read(databaseProvider);
    await db
        .into(db.settings)
        .insertOnConflictUpdate(SettingsCompanion(key: const Value(_key), value: Value(mode.name)));
  }
}
