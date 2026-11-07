// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'TopFlop';

  @override
  String get navOverview => 'Aperçu';

  @override
  String get navScan => 'Scanner';

  @override
  String get navStores => 'Magasins';

  @override
  String get homeTitle => 'Mes produits';

  @override
  String get homeSearchHint => 'Rechercher, p. ex. salami';

  @override
  String get homeSearchLabel => 'Rechercher des produits';

  @override
  String get filterAll => 'Tous les magasins';

  @override
  String get filterFavorites => 'Favoris';

  @override
  String get filterBuyAgain => 'À racheter';

  @override
  String get homeRecent => 'Notés récemment';

  @override
  String get homeResults => 'Résultats';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
    );
    return '$_temp0';
  }

  @override
  String get notBuyAgain => 'Ne rachèterait pas';

  @override
  String get homeEmptyTitle => 'Rien de noté pour l’instant';

  @override
  String get homeEmptyBody =>
      'Scanne ton premier produit en magasin et note à quel point il t’a plu.';

  @override
  String get homeNoMatchTitle => 'Introuvable';

  @override
  String homeNoMatchBody(String query) {
    return 'Tu n’as encore rien enregistré pour « $query ». Scanne le produit pour le noter.';
  }

  @override
  String get scanNow => 'Scanner';

  @override
  String get settings => 'Réglages';

  @override
  String get favorite => 'Favori';

  @override
  String get scanTitle => 'Scanner un code-barres';

  @override
  String get scanHint => 'Place le code-barres dans le cadre';

  @override
  String get scanEnterCode => 'Saisir le code';

  @override
  String get scanWithoutBarcode => 'Ajouter sans code-barres';

  @override
  String get scanTorch => 'Lampe';

  @override
  String get scanClose => 'Fermer';

  @override
  String get scanLooking => 'Recherche du produit …';

  @override
  String scanDetected(String code) {
    return 'Détecté · $code';
  }

  @override
  String scanAlreadyRated(int score) {
    return 'Déjà noté : $score sur 10';
  }

  @override
  String get scanLastAgainYes => 'Tu le rachèterais';

  @override
  String get scanLastAgainNo => 'Tu ne le rachèterais pas';

  @override
  String scanLastAt(String store) {
    return 'dernièrement chez $store';
  }

  @override
  String get scanNotFoundTitle => 'Produit inconnu';

  @override
  String get scanNotFoundBody =>
      'Open Food Facts n’a pas encore de données pour ce code-barres. Tu peux l’ajouter toi-même.';

  @override
  String get scanOffline =>
      'Pas de connexion. Tu peux quand même ajouter le produit toi-même.';

  @override
  String get scanCreateProduct => 'Ajouter manuellement';

  @override
  String get scanAgain => 'Scanner à nouveau';

  @override
  String get details => 'Détails';

  @override
  String get rate => 'Noter';

  @override
  String get dataSourceOff => 'Données produit d’Open Food Facts';

  @override
  String get cameraUnavailable =>
      'Caméra indisponible. Vérifie l’autorisation dans les réglages.';

  @override
  String get enterCodeTitle => 'Saisir le code-barres';

  @override
  String get enterCodeHint => 'p. ex. 4012345678901';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Rechercher';

  @override
  String get productBuyAgain => 'À racheter';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get productAvailableAt => 'Disponible chez';

  @override
  String get productNoRatings => 'Pas encore de note. C’était comment ?';

  @override
  String get productImageMissing => 'Aucune photo disponible';

  @override
  String get back => 'Retour';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteProductTitle => 'Supprimer le produit ?';

  @override
  String get deleteProductBody =>
      'Le produit et toutes ses notes seront supprimés.';

  @override
  String nutriScore(String grade) {
    return 'Nutri-Score $grade';
  }

  @override
  String get ratingTitle => 'Nouvelle note';

  @override
  String get ratingSliderLabel => 'Note de 1 à 10';

  @override
  String ratingTick(int n) {
    return 'Note $n sur 10';
  }

  @override
  String get ratingBuyAgainQuestion => 'Tu le rachèterais ?';

  @override
  String get ratingYes => 'Oui, volontiers';

  @override
  String get ratingNo => 'Plutôt pas';

  @override
  String get ratingWhere => 'Où le trouver ?';

  @override
  String get ratingLastStores => 'Comme la dernière fois';

  @override
  String get ratingOtherStore => 'Autre magasin';

  @override
  String get ratingPrice => 'Prix';

  @override
  String get ratingNote => 'Remarque';

  @override
  String get ratingNoteHint =>
      'Qu’est-ce qui était bien, qu’est-ce qui ne l’était pas ?';

  @override
  String get optional => '(facultatif)';

  @override
  String get ratingSave => 'Enregistrer la note';

  @override
  String get score1 => 'Immangeable';

  @override
  String get score2 => 'Horrible';

  @override
  String get score3 => 'Mauvais';

  @override
  String get score4 => 'Médiocre';

  @override
  String get score5 => 'Bof';

  @override
  String get score6 => 'Correct';

  @override
  String get score7 => 'Bon';

  @override
  String get score8 => 'Très bon';

  @override
  String get score9 => 'Excellent';

  @override
  String get score10 => 'Parfait';

  @override
  String get productFormTitle => 'Ajouter un produit';

  @override
  String get productFormName => 'Nom';

  @override
  String get productFormBrand => 'Marque';

  @override
  String get productFormQuantity => 'Quantité, p. ex. 200 g';

  @override
  String get productFormCategory => 'Catégorie';

  @override
  String get productFormNameRequired => 'Saisis un nom';

  @override
  String get continueToRating => 'Continuer vers la note';

  @override
  String get categoryMeat => 'Viande & charcuterie';

  @override
  String get categoryCheese => 'Fromage';

  @override
  String get categoryDrink => 'Boissons';

  @override
  String get categoryDairy => 'Produits laitiers';

  @override
  String get categoryBakery => 'Pain & viennoiseries';

  @override
  String get categorySweets => 'Sucreries & snacks';

  @override
  String get categoryProduce => 'Fruits & légumes';

  @override
  String get categoryHousehold => 'Maison & hygiène';

  @override
  String get categoryOther => 'Autre';

  @override
  String get storesTitle => 'Mes magasins';

  @override
  String get storesAll => 'Tous les magasins';

  @override
  String storesRatedCount(int count) {
    return '$count notés';
  }

  @override
  String storesTop(String product) {
    return 'Top : $product';
  }

  @override
  String get storesEmpty =>
      'Aucun magasin pour l’instant. Ajoute ton supermarché pour te souvenir où tu as trouvé quoi.';

  @override
  String get storesAdd => 'Ajouter un magasin';

  @override
  String get storeFormName => 'Magasin / enseigne';

  @override
  String get storeProducts => 'Disponible ici';

  @override
  String get save => 'Enregistrer';

  @override
  String get settingsBackup => 'Sauvegarde';

  @override
  String get settingsBackupInfo =>
      'Tes données sont sauvegardées automatiquement via ton compte Google ou iCloud. Tu peux aussi exporter un fichier de sauvegarde à tout moment.';

  @override
  String get settingsExport => 'Exporter les données';

  @override
  String get settingsImport => 'Importer des données';

  @override
  String settingsLastExport(String date) {
    return 'Dernier export : $date';
  }

  @override
  String get settingsNeverExported => 'Jamais exporté';

  @override
  String settingsDbSize(String size) {
    return 'Taille des données : $size';
  }

  @override
  String get settingsSizeWarning =>
      'La sauvegarde automatique approche de sa limite. Exporte tes données régulièrement.';

  @override
  String get settingsImportTitle => 'Importer des données ?';

  @override
  String get settingsImportBody =>
      'Toutes les données actuelles seront remplacées par la sauvegarde.';

  @override
  String get settingsImportDone => 'Import terminé';

  @override
  String get settingsImportFailed => 'Impossible de lire le fichier.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutBody =>
      'Les données et images des produits proviennent d’Open Food Facts (ODbL).';

  @override
  String get backupShareText => 'Sauvegarde TopFlop';

  @override
  String get homeAllProducts => 'Tous les produits';

  @override
  String get filterTitle => 'Filtres';

  @override
  String get filterReset => 'Réinitialiser';

  @override
  String get filterRemove => 'Retirer le filtre';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afficher $count produits',
      one: 'Afficher 1 produit',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get filterNoMatchBody => 'Aucun produit ne correspond à tes filtres.';

  @override
  String get sortTitle => 'Trier par';

  @override
  String get sortRecent => 'Notés récemment';

  @override
  String get sortBest => 'Tops d’abord';

  @override
  String get sortWorst => 'Flops d’abord';

  @override
  String get sortName => 'Nom A–Z';

  @override
  String get filterScore => 'Note';

  @override
  String get filterAny => 'Peu importe';

  @override
  String get filterFavoritesOnly => 'Favoris uniquement';

  @override
  String get filterStores => 'Magasins';

  @override
  String get filterCategories => 'Catégories';

  @override
  String filterCategoriesCount(int count) {
    return '$count catégories';
  }

  @override
  String get productEditTitle => 'Modifier le produit';

  @override
  String get categoryChoose => 'Choisir une catégorie';

  @override
  String get change => 'Modifier';

  @override
  String get storeFormNameHint => 'p. ex. Carrefour';

  @override
  String storeFormExists(String name) {
    return '$name existe déjà et sera sélectionné';
  }

  @override
  String get ratingChange => 'Modifier la note';

  @override
  String get productScore => 'Note';

  @override
  String productRatedOn(String date) {
    return 'Noté le $date';
  }

  @override
  String get productYourNote => 'Ta remarque';

  @override
  String get ratingWhereHint => 'Choisis autant de magasins que tu veux';

  @override
  String get ratingEditTitle => 'Modifier la note';

  @override
  String get storeEditTitle => 'Modifier le magasin';

  @override
  String get deleteStoreTitle => 'Supprimer le magasin ?';

  @override
  String get deleteStoreBody =>
      'Le magasin sera supprimé. Tes notes sont conservées.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';
}
