import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_type.dart';

part 'product_item.freezed.dart';

@freezed
class ProductItem with _$ProductItem {
  const ProductItem._();

  const factory ProductItem({
    required String id,
    required String barcode,
    required String name,
    String? brand,
    String? store,
    required int rating,
    String? notes,
    String? imageUrl,
    required DateTime createdAt,
    String? category,
    String? ingredients,
    String? localImagePath,
    @Default(ProductType.food) ProductType productType,
    double? price,
  }) = _ProductItem;

  String get ratingEmoji {
    switch (rating) {
      case 1:
        return '🤮';
      case 2:
        return '😖';
      case 3:
        return '😣';
      case 4:
        return '😕';
      case 5:
        return '😐';
      case 6:
        return '🙂';
      case 7:
        return '😊';
      case 8:
        return '😋';
      case 9:
        return '🤩';
      case 10:
        return '😍';
      default:
        return '❓';
    }
  }
}
