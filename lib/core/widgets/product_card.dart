import 'package:flutter/material.dart';

import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import '../domain/product_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import 'score_badge.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.summary, required this.onTap});

  final ProductSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = summary.product;
    final meta = [p.brand, summary.storeName].whereType<String>().join(' · ');
    final score = summary.score;

    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.colors.borderSoft),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductImage(category: ProductCategory.fromName(p.category), imageUrl: p.imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(16, weight: FontWeight.w600),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(13, color: context.colors.muted),
                      ),
                    ],
                    if (summary.wouldBuyAgain == false) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colors.subtle,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          l10n.notBuyAgain,
                          style: AppText.body(12, weight: FontWeight.w600, color: context.colors.muted),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (score != null) ScoreBadge(score: score),
                  if (p.isFavorite) ...[
                    const SizedBox(height: 4),
                    Icon(Icons.favorite_rounded, size: 16, color: context.colors.primary, semanticLabel: l10n.favorite),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
