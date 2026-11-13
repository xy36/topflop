import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/product_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

/// Grid of all categories with placeholder tile.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.selected, required this.onSelected});

  final ProductCategory selected;
  final ValueChanged<ProductCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      padding: EdgeInsets.zero,
      children: [
        for (final c in ProductCategory.values)
          _CategoryOption(category: c, label: c.label(l10n), selected: c == selected, onTap: () => onSelected(c)),
      ],
    );
  }
}

/// Bottom sheet for picking a category; returns `null` when cancelled.
Future<ProductCategory?> showCategoryPicker(BuildContext context, ProductCategory current) {
  return showModalBottomSheet<ProductCategory>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.paddingOf(context).bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context).categoryChoose, style: AppText.display(24)),
          const SizedBox(height: 16),
          CategoryGrid(selected: current, onSelected: (c) => Navigator.pop(context, c)),
        ],
      ),
    ),
  );
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({required this.category, required this.label, required this.selected, required this.onTap});

  final ProductCategory category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? context.colors.primary : context.colors.borderSoft,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProductImage(category: category, size: 44, radius: 12),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, weight: selected ? FontWeight.w700 : FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
