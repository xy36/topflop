import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product_item.dart';
import '../models/product_type.dart';
import '../providers/food_provider.dart';
import '../services/backup_service.dart';
import 'add_food_screen.dart';
import 'barcode_scanner_screen.dart';
import 'food_detail_screen.dart';
import 'product_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFoodItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBackupDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Backup',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.upload,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Backup exportieren'),
                  subtitle: const Text('ZIP-Datei speichern oder teilen'),
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final colorScheme = Theme.of(context).colorScheme;
                    Navigator.pop(context);
                    try {
                      await BackupService().exportBackup();
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Fehler: $e',
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                            backgroundColor: colorScheme.errorContainer,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: const Text('Backup importieren'),
                  subtitle: const Text('ZIP-Datei wiederherstellen'),
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final colorScheme = Theme.of(context).colorScheme;
                    final foodProvider = context.read<FoodProvider>();
                    Navigator.pop(context);
                    try {
                      final count = await BackupService().importBackup();
                      if (count == null || !mounted) return;
                      foodProvider.loadFoodItems();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '$count Produkte wiederhergestellt',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          backgroundColor: colorScheme.secondaryContainer,
                        ),
                      );
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Fehler: $e',
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                            backgroundColor: colorScheme.errorContainer,
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Produkt hinzufügen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Barcode scannen'),
                  subtitle: const Text('Mit der Kamera scannen'),
                  onTap: () {
                    Navigator.pop(context);
                    _openScanner();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: const Text('Produkt suchen'),
                  subtitle: const Text('In der Datenbank suchen'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const ProductSearchScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                  title: const Text('Manuell eingeben'),
                  subtitle: const Text('Selbst erfassen'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const AddFoodScreen(barcode: ''),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _openScanner() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result == true) {
      // Liste wurde aktualisiert
    }
  }

  void _openFoodDetail(ProductItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FoodDetailScreen(item: item)),
    );
  }

  void _showSortDialog() {
    final foodProvider = context.read<FoodProvider>();

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sortieren nach',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Name (A-Z)'),
                  trailing:
                      foodProvider.sortOption == SortOption.nameAsc
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    foodProvider.setSortOption(SortOption.nameAsc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Name (Z-A)'),
                  trailing:
                      foodProvider.sortOption == SortOption.nameDesc
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    foodProvider.setSortOption(SortOption.nameDesc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Bewertung (niedrig → hoch)'),
                  trailing:
                      foodProvider.sortOption == SortOption.ratingAsc
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    foodProvider.setSortOption(SortOption.ratingAsc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Bewertung (hoch → niedrig)'),
                  trailing:
                      foodProvider.sortOption == SortOption.ratingDesc
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    foodProvider.setSortOption(SortOption.ratingDesc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Datum (älteste zuerst)'),
                  trailing:
                      foodProvider.sortOption == SortOption.dateAsc
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    foodProvider.setSortOption(SortOption.dateAsc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Datum (neueste zuerst)'),
                  trailing:
                      foodProvider.sortOption == SortOption.dateDesc
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    foodProvider.setSortOption(SortOption.dateDesc);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterChips(FoodProvider foodProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Rating Filter
          FilterChip(
            label: Text(
              foodProvider.filterMinRating != null
                  ? '${foodProvider.filterMinRating}-${foodProvider.filterMaxRating ?? 10} ⭐'
                  : 'Bewertung',
            ),
            selected: foodProvider.filterMinRating != null,
            onSelected: (_) => _showRatingFilterDialog(),
          ),
          const SizedBox(width: 8),
          // Store Filter
          if (foodProvider.uniqueStores.isNotEmpty)
            FilterChip(
              label: Text(foodProvider.filterStore ?? 'Geschäft'),
              selected: foodProvider.filterStore != null,
              onSelected: (_) => _showStoreFilterDialog(),
            ),
          const SizedBox(width: 8),
          // Brand Filter
          if (foodProvider.uniqueBrands.isNotEmpty)
            FilterChip(
              label: Text(foodProvider.filterBrand ?? 'Marke'),
              selected: foodProvider.filterBrand != null,
              onSelected: (_) => _showBrandFilterDialog(),
            ),
          const SizedBox(width: 8),
          // Produkttyp Filter
          ...ProductType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${type.icon} ${type.label}'),
                selected: foodProvider.filterProductType == type,
                onSelected:
                    (_) => foodProvider.setProductTypeFilter(
                      foodProvider.filterProductType == type ? null : type,
                    ),
              ),
            ),
          ),
          // Clear Filters
          if (foodProvider.filterMinRating != null ||
              foodProvider.filterStore != null ||
              foodProvider.filterBrand != null ||
              foodProvider.filterProductType != null)
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: const Text('Filter löschen'),
              onPressed: () => foodProvider.clearFilters(),
            ),
        ],
      ),
    );
  }

  void _showRatingFilterDialog() {
    final foodProvider = context.read<FoodProvider>();
    RangeValues currentRange = RangeValues(
      (foodProvider.filterMinRating ?? 1).toDouble(),
      (foodProvider.filterMaxRating ?? 10).toDouble(),
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Bewertung filtern'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currentRange.start.round()} - ${currentRange.end.round()}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      RangeSlider(
                        values: currentRange,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        labels: RangeLabels(
                          currentRange.start.round().toString(),
                          currentRange.end.round().toString(),
                        ),
                        onChanged: (values) {
                          setState(() => currentRange = values);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        foodProvider.setRatingFilter(null, null);
                        Navigator.pop(context);
                      },
                      child: const Text('Zurücksetzen'),
                    ),
                    FilledButton(
                      onPressed: () {
                        foodProvider.setRatingFilter(
                          currentRange.start.round(),
                          currentRange.end.round(),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Anwenden'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showStoreFilterDialog() {
    final foodProvider = context.read<FoodProvider>();
    final stores = foodProvider.uniqueStores;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Geschäft auswählen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (foodProvider.filterStore != null)
                  ListTile(
                    leading: const Icon(Icons.clear),
                    title: const Text('Filter entfernen'),
                    onTap: () {
                      foodProvider.setStoreFilter(null);
                      Navigator.pop(context);
                    },
                  ),
                ...stores.map(
                  (store) => ListTile(
                    leading: const Icon(Icons.store),
                    title: Text(store),
                    trailing:
                        foodProvider.filterStore == store
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () {
                      foodProvider.setStoreFilter(store);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showBrandFilterDialog() {
    final foodProvider = context.read<FoodProvider>();
    final brands = foodProvider.uniqueBrands;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Marke auswählen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (foodProvider.filterBrand != null)
                  ListTile(
                    leading: const Icon(Icons.clear),
                    title: const Text('Filter entfernen'),
                    onTap: () {
                      foodProvider.setBrandFilter(null);
                      Navigator.pop(context);
                    },
                  ),
                ...brands.map(
                  (brand) => ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(brand),
                    trailing:
                        foodProvider.filterBrand == brand
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () {
                      foodProvider.setBrandFilter(brand);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Suchen...',
                    border: InputBorder.none,
                    filled: false,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                  onChanged:
                      (value) =>
                          context.read<FoodProvider>().setSearchQuery(value),
                )
                : const Text('Meine Produkte'),
        leading:
            _isSearching
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _searchController.clear();
                    context.read<FoodProvider>().setSearchQuery('');
                    setState(() => _isSearching = false);
                  },
                )
                : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
              tooltip: 'Suchen',
            ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              if (_showFilters) {
                context.read<FoodProvider>().clearFilters();
              }
              setState(() => _showFilters = !_showFilters);
            },
            tooltip: 'Filter anzeigen',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sortieren',
          ),
          IconButton(
            icon: const Icon(Icons.backup_outlined),
            onPressed: _showBackupDialog,
            tooltip: 'Backup',
          ),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          return Column(
            children: [
              // Statistik-Row
              if (!_isSearching &&
                  !_showFilters &&
                  foodProvider.allItems.isNotEmpty)
                _buildStatsRow(foodProvider),

              // Filter Chips
              if (_showFilters) ...[
                _buildFilterChips(foodProvider),
                const SizedBox(height: 8),
              ],

              // Ergebnis-Info
              if (foodProvider.searchQuery.isNotEmpty ||
                  foodProvider.filterMinRating != null ||
                  foodProvider.filterStore != null ||
                  foodProvider.filterBrand != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${foodProvider.foodItems.length} Ergebnis${foodProvider.foodItems.length != 1 ? 'se' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

              // Liste
              Expanded(
                child:
                    foodProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : foodProvider.foodItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: foodProvider.foodItems.length,
                          itemBuilder: (context, index) {
                            final item = foodProvider.foodItems[index];
                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              dismissThresholds: const {
                                DismissDirection.endToStart: 0.5,
                              },
                              movementDuration: const Duration(
                                milliseconds: 300,
                              ),
                              background: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              confirmDismiss: (_) async {
                                HapticFeedback.mediumImpact();
                                await foodProvider.deleteFoodItem(item.id);
                                if (!context.mounted) return false;
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('„${item.name}" gelöscht'),
                                    action: SnackBarAction(
                                      label: 'Rückgängig',
                                      onPressed: () async {
                                        await foodProvider.addFoodItem(item);
                                      },
                                    ),
                                  ),
                                );
                                return false; // Liste wird durch Provider-Update aktualisiert
                              },
                              child: _FoodItemCard(
                                item: item,
                                onTap: () => _openFoodDetail(item),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add',
        onPressed: _showAddOptions,
        tooltip: 'Produkt hinzufügen',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsRow(FoodProvider foodProvider) {
    final items = foodProvider.allItems;
    final avgRating =
        items.isEmpty
            ? 0.0
            : items.map((i) => i.rating).reduce((a, b) => a + b) / items.length;

    // Häufigster Store
    final storeCounts = <String, int>{};
    for (final item in items) {
      if (item.store != null) {
        storeCounts[item.store!] = (storeCounts[item.store!] ?? 0) + 1;
      }
    }
    final topStore =
        storeCounts.isNotEmpty
            ? (storeCounts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key
            : null;

    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.5),
    );
    final valueStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _statItem('Produkte', '${items.length}', labelStyle!, valueStyle!),
          _statDivider(scheme),
          _statItem(
            'Ø Bewertung',
            avgRating.toStringAsFixed(1),
            labelStyle,
            valueStyle,
          ),
          if (topStore != null) ...[
            _statDivider(scheme),
            Expanded(
              child: _statItem('Top Store', topStore, labelStyle, valueStyle),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statItem(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(value, style: valueStyle),
          const SizedBox(height: 2),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }

  Widget _statDivider(ColorScheme scheme) {
    return Container(height: 24, width: 1, color: scheme.outlineVariant);
  }

  Widget _buildEmptyState() {
    final foodProvider = context.read<FoodProvider>();
    final hasFilters =
        foodProvider.searchQuery.isNotEmpty ||
        foodProvider.filterMinRating != null ||
        foodProvider.filterStore != null ||
        foodProvider.filterBrand != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.restaurant_menu,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'Keine Ergebnisse gefunden' : 'Noch keine Produkte',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Versuche andere Suchbegriffe oder Filter'
                  : 'Scanne deinen ersten Barcode!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  foodProvider.clearFilters();
                  setState(() => _isSearching = false);
                },
                icon: const Icon(Icons.clear),
                label: const Text('Filter zurücksetzen'),
              ),
            ] else ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _showBackupDialog,
                icon: const Icon(Icons.restore),
                label: const Text('Backup importieren'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final ProductItem item;
  final VoidCallback onTap;

  const _FoodItemCard({required this.item, required this.onTap});

  Color _ratingColor(int rating) {
    if (rating <= 3) return const Color(0xFFE53935);
    if (rating <= 6) return const Color(0xFFFB8C00);
    return const Color(0xFF43A047);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratingColor = _ratingColor(item.rating);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Bild
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child:
                        item.localImagePath != null
                            ? Image.file(
                              File(item.localImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _placeholder(scheme),
                            )
                            : item.imageUrl != null
                            ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _placeholder(scheme),
                            )
                            : _placeholder(scheme),
                  ),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.brand != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.brand!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (item.store != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 12,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.store!,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Rating Badge
                Column(
                  children: [
                    Text(
                      item.ratingEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ratingColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.rating}/10',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ratingColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.restaurant_outlined,
        size: 32,
        color: scheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
