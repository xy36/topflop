import '../db/database.dart';

/// A product with its rating and the stores that carry it.
class ProductSummary {
  const ProductSummary({required this.product, required this.rating, required this.stores});

  final Product product;

  /// `null` as long as the product has not been rated.
  final Rating? rating;

  /// Sorted by name.
  final List<Store> stores;

  bool get isRated => rating != null;

  int? get score => rating?.score;

  bool? get wouldBuyAgain => rating?.wouldBuyAgain;

  /// For display in lists: the first store (alphabetically).
  String? get storeName => stores.isEmpty ? null : stores.first.name;

  DateTime get lastActivity => rating?.ratedAt ?? product.createdAt;
}

class StoreSummary {
  const StoreSummary({required this.store, required this.products});

  /// The chain.
  final Store store;

  /// Products available here, best rated first.
  final List<ProductSummary> products;

  int get ratedCount => products.length;
  ProductSummary? get top => products.isEmpty ? null : products.first;
}
