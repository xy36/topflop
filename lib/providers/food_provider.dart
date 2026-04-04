import 'package:flutter/foundation.dart';

import '../models/product_item.dart';
import '../models/product_type.dart';
import '../services/database_service.dart';

enum SortOption { nameAsc, nameDesc, ratingAsc, ratingDesc, dateAsc, dateDesc }

class FoodProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<ProductItem> _allItems = [];
  List<ProductItem> _filteredItems = [];

  String _searchQuery = '';
  int? _filterMinRating;
  int? _filterMaxRating;
  String? _filterStore;
  String? _filterBrand;
  ProductType? _filterProductType;
  SortOption _sortOption = SortOption.dateDesc;
  bool _isLoading = false;

  List<ProductItem> get items => _filteredItems;
  // keep old name for screens that use it
  List<ProductItem> get foodItems => _filteredItems;
  List<ProductItem> get allItems => _allItems;

  String get searchQuery => _searchQuery;
  int? get filterMinRating => _filterMinRating;
  int? get filterMaxRating => _filterMaxRating;
  String? get filterStore => _filterStore;
  String? get filterBrand => _filterBrand;
  ProductType? get filterProductType => _filterProductType;
  SortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;

  List<String> get uniqueStores => _db.getUniqueStores();
  List<String> get uniqueBrands => _db.getUniqueBrands();
  List<ProductType> get usedProductTypes => _db.getUsedProductTypes();

  Future<void> loadFoodItems() async {
    _isLoading = true;
    notifyListeners();
    _allItems = _db.getAllItems();
    _applyFiltersAndSort();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFoodItem(ProductItem item) async {
    await _db.addItem(item);
    _allItems = _db.getAllItems();
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> updateFoodItem(ProductItem item) async {
    await _db.updateItem(item);
    _allItems = _db.getAllItems();
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> deleteFoodItem(String id) async {
    await _db.deleteItem(id);
    _allItems = _db.getAllItems();
    _applyFiltersAndSort();
    notifyListeners();
  }

  ProductItem? findByBarcode(String barcode) => _db.findByBarcode(barcode);

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setRatingFilter(int? min, int? max) {
    _filterMinRating = min;
    _filterMaxRating = max;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setStoreFilter(String? store) {
    _filterStore = store;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setBrandFilter(String? brand) {
    _filterBrand = brand;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setProductTypeFilter(ProductType? type) {
    _filterProductType = type;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterMinRating = null;
    _filterMaxRating = null;
    _filterStore = null;
    _filterBrand = null;
    _filterProductType = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    var result = List<ProductItem>.from(_allItems);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((item) {
        return item.name.toLowerCase().contains(q) ||
            (item.brand?.toLowerCase().contains(q) ?? false) ||
            (item.store?.toLowerCase().contains(q) ?? false) ||
            (item.category?.toLowerCase().contains(q) ?? false) ||
            item.barcode.contains(q);
      }).toList();
    }

    if (_filterMinRating != null || _filterMaxRating != null) {
      final min = _filterMinRating ?? 1;
      final max = _filterMaxRating ?? 10;
      result = result.where((i) => i.rating >= min && i.rating <= max).toList();
    }

    if (_filterStore != null) {
      result = result
          .where((i) =>
              i.store?.toLowerCase() == _filterStore!.toLowerCase())
          .toList();
    }

    if (_filterBrand != null) {
      result = result
          .where((i) =>
              i.brand?.toLowerCase() == _filterBrand!.toLowerCase())
          .toList();
    }

    if (_filterProductType != null) {
      result =
          result.where((i) => i.productType == _filterProductType).toList();
    }

    switch (_sortOption) {
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SortOption.nameDesc:
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case SortOption.ratingAsc:
        result.sort((a, b) => a.rating.compareTo(b.rating));
      case SortOption.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortOption.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _filteredItems = result;
  }
}
