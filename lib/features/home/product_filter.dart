import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/product_category.dart';
import '../../core/domain/score.dart';
import '../../data/repositories/models.dart';

enum ProductSort { recent, bestRated, worstRated, name }

/// Filter und Sortierung der Produktübersicht.
class ProductFilter {
  const ProductFilter({
    this.minScore = Score.min,
    this.maxScore = Score.max,
    this.favoritesOnly = false,
    this.buyAgain,
    this.storeIds = const {},
    this.categories = const {},
    this.sort = ProductSort.recent,
  });

  final int minScore;
  final int maxScore;
  final bool favoritesOnly;

  /// `null`: egal, sonst nur Produkte mit diesem letzten Urteil.
  final bool? buyAgain;

  /// Leer: alle Läden. Sonst: mindestens ein Kauf in einem dieser Läden.
  final Set<int> storeIds;

  /// Leer: alle Kategorien.
  final Set<ProductCategory> categories;

  final ProductSort sort;

  bool get scoreActive => minScore > Score.min || maxScore < Score.max;

  /// Anzahl aktiver Filter (ohne Sortierung) – für das Badge am Filterknopf.
  int get activeCount => [
    scoreActive,
    favoritesOnly,
    buyAgain != null,
    storeIds.isNotEmpty,
    categories.isNotEmpty,
  ].where((active) => active).length;

  bool get isActive => activeCount > 0;

  bool matches(ProductSummary s) {
    if (favoritesOnly && !s.product.isFavorite) return false;
    if (buyAgain != null && s.wouldBuyAgain != buyAgain) return false;
    if (categories.isNotEmpty && !categories.contains(ProductCategory.fromName(s.product.category))) return false;
    if (storeIds.isNotEmpty && !s.stores.any((st) => storeIds.contains(st.id))) return false;
    if (scoreActive) {
      final score = s.score;
      if (score == null || score < minScore || score > maxScore) return false;
    }
    return true;
  }

  List<ProductSummary> apply(Iterable<ProductSummary> items) {
    final result = items.where(matches).toList();
    int byScore(ProductSummary a, ProductSummary b) => (a.score ?? 0).compareTo(b.score ?? 0);
    switch (sort) {
      case ProductSort.recent:
        result.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      case ProductSort.bestRated:
        result.sort((a, b) => byScore(b, a));
      case ProductSort.worstRated:
        // Unbewertete Produkte ans Ende, nicht an den Anfang.
        result.sort((a, b) => (a.score ?? 99).compareTo(b.score ?? 99));
      case ProductSort.name:
        result.sort((a, b) => a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase()));
    }
    return result;
  }

  ProductFilter copyWith({
    int? minScore,
    int? maxScore,
    bool? favoritesOnly,
    bool? Function()? buyAgain,
    Set<int>? storeIds,
    Set<ProductCategory>? categories,
    ProductSort? sort,
  }) => ProductFilter(
    minScore: minScore ?? this.minScore,
    maxScore: maxScore ?? this.maxScore,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    buyAgain: buyAgain != null ? buyAgain() : this.buyAgain,
    storeIds: storeIds ?? this.storeIds,
    categories: categories ?? this.categories,
    sort: sort ?? this.sort,
  );

  /// Setzt alle Filter zurück, behält aber die Sortierung.
  ProductFilter cleared() => ProductFilter(sort: sort);
}

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void set(ProductFilter filter) => state = filter;

  void clear() => state = state.cleared();
}

/// Bleibt beim Tab-Wechsel erhalten.
final productFilterProvider = NotifierProvider<ProductFilterNotifier, ProductFilter>(ProductFilterNotifier.new);
