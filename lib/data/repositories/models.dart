import '../db/database.dart';

class RatingWithStore {
  const RatingWithStore(this.rating, this.store);

  final Rating rating;
  final Store? store;
}

/// Ein Produkt mit verdichteten Bewertungsdaten für Listen.
class ProductSummary {
  const ProductSummary({required this.product, required this.ratings});

  final Product product;

  /// Neueste zuerst.
  final List<RatingWithStore> ratings;

  bool get hasRatings => ratings.isNotEmpty;
  int get ratingCount => ratings.length;
  RatingWithStore? get latest => ratings.isEmpty ? null : ratings.first;

  double? get averageScore =>
      ratings.isEmpty ? null : ratings.map((r) => r.rating.score).reduce((a, b) => a + b) / ratings.length;

  /// Für Badges: gerundeter Durchschnitt.
  int? get displayScore => averageScore?.round();

  /// Das Urteil der letzten Bewertung zählt.
  bool? get wouldBuyAgain => latest?.rating.wouldBuyAgain;

  String? get lastStoreName => ratings.map((r) => r.store?.name).firstWhere((n) => n != null, orElse: () => null);

  DateTime get lastActivity => latest?.rating.ratedAt ?? product.createdAt;

  /// Alle Läden, in denen das Produkt gekauft wurde, ohne Duplikate.
  List<Store> get stores {
    final seen = <int>{};
    return [
      for (final r in ratings)
        if (r.store != null && seen.add(r.store!.id)) r.store!,
    ];
  }
}

class StoreSummary {
  const StoreSummary({required this.store, required this.products});

  final Store store;

  /// Produkte, die hier gekauft wurden, bestbewertete zuerst.
  final List<ProductSummary> products;

  int get ratedCount => products.length;
  ProductSummary? get top => products.isEmpty ? null : products.first;
}
