enum ProductType {
  food,
  beauty,
  household,
  petFood,
  other;

  String get label {
    switch (this) {
      case ProductType.food:
        return 'Lebensmittel';
      case ProductType.beauty:
        return 'Kosmetik & Pflege';
      case ProductType.household:
        return 'Haushalt';
      case ProductType.petFood:
        return 'Tierfutter';
      case ProductType.other:
        return 'Sonstiges';
    }
  }

  String get icon {
    switch (this) {
      case ProductType.food:
        return '🍎';
      case ProductType.beauty:
        return '💄';
      case ProductType.household:
        return '🧹';
      case ProductType.petFood:
        return '🐾';
      case ProductType.other:
        return '📦';
    }
  }

  List<String> get subcategories {
    switch (this) {
      case ProductType.food:
        return [
          'Obst & Gemüse',
          'Milchprodukte',
          'Fleisch & Fisch',
          'Brot & Backwaren',
          'Getränke',
          'Süßes & Snacks',
          'Tiefkühl',
          'Konserven & Fertiggerichte',
          'Gewürze & Saucen',
          'Frühstück & Müsli',
        ];
      case ProductType.beauty:
        return [
          'Haarpflege',
          'Hautpflege',
          'Zahnpflege',
          'Deo & Parfum',
          'Seife & Duschgel',
          'Schminke',
        ];
      case ProductType.household:
        return [
          'Reinigung',
          'Waschmittel',
          'Küche',
          'Papier & Tücher',
        ];
      case ProductType.petFood:
        return [
          'Hundefutter',
          'Katzenfutter',
          'Leckerlis',
          'Pflege',
        ];
      case ProductType.other:
        return [];
    }
  }
}
