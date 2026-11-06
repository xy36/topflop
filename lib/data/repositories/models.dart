import '../db/database.dart';

/// Ein Produkt mit seiner Bewertung und den Läden, in denen es das gibt.
class ProductSummary {
  const ProductSummary({required this.product, required this.rating, required this.stores});

  final Product product;

  /// `null`, solange das Produkt noch nicht bewertet ist.
  final Rating? rating;

  /// Nach Name sortiert.
  final List<Store> stores;

  bool get isRated => rating != null;

  int? get score => rating?.score;

  bool? get wouldBuyAgain => rating?.wouldBuyAgain;

  /// Für die Anzeige in Listen: erster Laden (alphabetisch).
  String? get storeName => stores.isEmpty ? null : stores.first.name;

  DateTime get lastActivity => rating?.ratedAt ?? product.createdAt;
}

class StoreSummary {
  const StoreSummary({required this.store, required this.locations, required this.products});

  /// Die Kette.
  final Store store;

  /// Bekannte Filialen der Kette.
  final List<StoreLocation> locations;

  /// Produkte, die es hier gibt, bestbewertete zuerst.
  final List<ProductSummary> products;

  int get ratedCount => products.length;
  ProductSummary? get top => products.isEmpty ? null : products.first;

  /// Nächstgelegene Filiale und ihre Entfernung in Metern; `null` ohne Standort.
  (StoreLocation, double)? nearest(double Function(double lat, double lon)? distanceTo) {
    if (distanceTo == null || locations.isEmpty) return null;
    final measured = [for (final l in locations) (l, distanceTo(l.latitude, l.longitude))]
      ..sort((a, b) => a.$2.compareTo(b.$2));
    return measured.first;
  }
}
