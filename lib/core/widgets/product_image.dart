import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/product_category.dart';

/// Produktbild von Open Food Facts oder – falls keins vorhanden – eine
/// farbige Kategorie-Kachel als bewusst gestalteter Platzhalter.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.category,
    this.imageUrl,
    this.size = 56,
    this.radius = 14,
    this.iconSize,
  });

  final ProductCategory category;
  final String? imageUrl;
  final double size;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = CategoryTile(category: category, iconSize: iconSize ?? size * 0.5);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: imageUrl == null
            ? placeholder
            : ColoredBox(
                color: Colors.white,
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => placeholder,
                  errorWidget: (_, _, _) => placeholder,
                ),
              ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, this.iconSize = 28, this.strokeWidth = 1.6});

  final ProductCategory category;
  final double iconSize;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ColoredBox(
      color: category.tileFor(brightness),
      child: Center(
        child: SvgPicture.string(
          category.svg(strokeWidth: strokeWidth),
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(category.inkFor(brightness), BlendMode.srcIn),
        ),
      ),
    );
  }
}
