import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Kategorie eines Produkts. Steuert den Platzhalter, wenn kein Foto vorhanden ist.
enum ProductCategory {
  meat(
    tile: Color(0xFFF5DCD4),
    ink: Color(0xFF7A2E1C),
    icon:
        '<circle cx="12" cy="12" r="8"/><circle cx="9" cy="10" r="1.2"/><circle cx="14.5" cy="9" r="1"/>'
        '<circle cx="13.5" cy="14.5" r="1.3"/><circle cx="8.8" cy="14.6" r="0.9"/>',
    offTags: ['meats', 'sausages', 'salamis', 'hams', 'meat', 'poultry', 'fishes', 'seafood'],
  ),
  cheese(
    tile: Color(0xFFF6EBBE),
    ink: Color(0xFF6B4E07),
    icon:
        '<path d="M3 17.5 21 9.5v8H3z"/><path d="M21 9.5 13.5 5 3 17.5"/>'
        '<circle cx="15" cy="14" r="1.2"/><circle cx="10" cy="15.3" r="0.9"/>',
    offTags: ['cheeses'],
  ),
  drink(
    tile: Color(0xFFD7E8EE),
    ink: Color(0xFF1D4A5A),
    icon: '<path d="M8 3h8v3l2 3v12H6V9l2-3z"/><path d="M6 9h12M10 13h4"/>',
    offTags: ['beverages', 'plant-based-beverages', 'waters', 'juices', 'coffees', 'teas', 'beers', 'wines'],
  ),
  dairy(
    tile: Color(0xFFE5E0F3),
    ink: Color(0xFF3F2F73),
    icon: '<path d="M5.5 8h13l-1.4 12H6.9z"/><path d="M4 5h16v3H4z"/>',
    offTags: ['dairies', 'yogurts', 'milks', 'desserts', 'creams', 'butters'],
  ),
  bakery(
    tile: Color(0xFFECDDC7),
    ink: Color(0xFF5E3B12),
    icon: '<path d="M5 11.5A3.5 3.5 0 0 1 7 5h10a3.5 3.5 0 0 1 2 6.5V19H5z"/><path d="M9.5 8.5v3M14.5 8.5v3"/>',
    offTags: ['breads', 'bakery-products', 'pastries', 'cereals-and-potatoes'],
  ),
  sweets(
    tile: Color(0xFFF7DCE6),
    ink: Color(0xFF7A1F45),
    icon: '<rect x="6" y="7" width="12" height="10" rx="2"/><path d="M6 10 3 7.5v9L6 14M18 10l3-2.5v9L18 14"/>',
    offTags: ['sweet-snacks', 'snacks', 'chocolates', 'confectioneries', 'biscuits-and-cakes', 'salty-snacks'],
  ),
  produce(
    tile: Color(0xFFDDEDCF),
    ink: Color(0xFF2F5A17),
    icon: '<path d="M12 8c-4 0-6 3-6 6.5S8.5 21 12 21s6-3 6-6.5S16 8 12 8z"/><path d="M12 8c0-2 1-4 3-5"/>',
    offTags: ['fruits', 'vegetables', 'fresh-foods', 'plant-based-foods'],
  ),
  household(
    tile: Color(0xFFDDE3EA),
    ink: Color(0xFF2E3D4F),
    icon: '<path d="M9 3h6v4l2 2v12H7V9l2-2z"/><path d="M7 13h10"/>',
    offTags: [],
  ),
  other(
    tile: Color(0xFFE6E9E1),
    ink: Color(0xFF3E4A42),
    icon: '<path d="M4 8.5 12 4l8 4.5v7L12 20l-8-4.5z"/><path d="M4 8.5 12 13l8-4.5M12 13v7"/>',
    offTags: [],
  );

  const ProductCategory({required this.tile, required this.ink, required this.icon, required this.offTags});

  final Color tile;
  final Color ink;

  /// SVG-Pfade (viewBox 0 0 24 24, Strichgrafik).
  final String icon;

  /// Open-Food-Facts-Kategorien (ohne Sprachpräfix), die auf diese Kategorie abbilden.
  final List<String> offTags;

  String svg({double strokeWidth = 1.6}) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
      'stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">$icon</svg>';

  String label(AppLocalizations l10n) => switch (this) {
    meat => l10n.categoryMeat,
    cheese => l10n.categoryCheese,
    drink => l10n.categoryDrink,
    dairy => l10n.categoryDairy,
    bakery => l10n.categoryBakery,
    sweets => l10n.categorySweets,
    produce => l10n.categoryProduce,
    household => l10n.categoryHousehold,
    other => l10n.categoryOther,
  };

  static ProductCategory fromName(String? name) =>
      ProductCategory.values.firstWhere((c) => c.name == name, orElse: () => other);

  /// Wählt die spezifischste passende Kategorie aus den OFF-Tags (z. B. `en:salamis`).
  static ProductCategory fromOffTags(List<String> tags) {
    final plain = tags.map((t) => t.contains(':') ? t.split(':').last : t).toList();
    // Spezifische Tags stehen bei OFF am Ende der Liste.
    for (final tag in plain.reversed) {
      for (final category in ProductCategory.values) {
        if (category.offTags.contains(tag)) return category;
      }
    }
    return other;
  }
}
