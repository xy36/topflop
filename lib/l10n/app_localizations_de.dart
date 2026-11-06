// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'TopFlop';

  @override
  String get navOverview => 'Übersicht';

  @override
  String get navScan => 'Scannen';

  @override
  String get navStores => 'Läden';

  @override
  String get homeTitle => 'Meine Produkte';

  @override
  String get homeSearchHint => 'Suchen, z. B. Salami';

  @override
  String get homeSearchLabel => 'Produkte durchsuchen';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterFavorites => 'Favoriten';

  @override
  String get filterBuyAgain => 'Wieder kaufen';

  @override
  String get homeRecent => 'Zuletzt bewertet';

  @override
  String get homeResults => 'Treffer';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
    );
    return '$_temp0';
  }

  @override
  String get notBuyAgain => 'Nicht wieder kaufen';

  @override
  String get homeEmptyTitle => 'Noch nichts bewertet';

  @override
  String get homeEmptyBody =>
      'Scanne dein erstes Produkt im Laden und halte fest, wie es dir geschmeckt hat.';

  @override
  String get homeNoMatchTitle => 'Nicht gefunden';

  @override
  String homeNoMatchBody(String query) {
    return 'Zu „$query“ hast du noch nichts gespeichert. Scanne das Produkt, um es zu bewerten.';
  }

  @override
  String get scanNow => 'Jetzt scannen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get favorite => 'Favorit';

  @override
  String get scanTitle => 'Barcode scannen';

  @override
  String get scanHint => 'Halte den Barcode in den Rahmen';

  @override
  String get scanEnterCode => 'Code eintippen';

  @override
  String get scanWithoutBarcode => 'Ohne Barcode anlegen';

  @override
  String get scanTorch => 'Taschenlampe';

  @override
  String get scanClose => 'Schließen';

  @override
  String get scanLooking => 'Suche Produkt …';

  @override
  String scanDetected(String code) {
    return 'Erkannt · $code';
  }

  @override
  String scanAlreadyRated(int score) {
    return 'Schon bewertet: $score von 10';
  }

  @override
  String get scanLastAgainYes => 'Würdest du wieder kaufen';

  @override
  String get scanLastAgainNo => 'Würdest du nicht wieder kaufen';

  @override
  String scanLastAt(String store) {
    return 'zuletzt bei $store';
  }

  @override
  String get scanNotFoundTitle => 'Produkt unbekannt';

  @override
  String get scanNotFoundBody =>
      'Zu diesem Barcode gibt es noch keine Daten bei Open Food Facts. Du kannst es selbst anlegen.';

  @override
  String get scanOffline =>
      'Keine Verbindung. Du kannst das Produkt trotzdem selbst anlegen.';

  @override
  String get scanCreateProduct => 'Selbst anlegen';

  @override
  String get scanAgain => 'Nochmal scannen';

  @override
  String get details => 'Details';

  @override
  String get rateNew => 'Neu bewerten';

  @override
  String get rate => 'Bewerten';

  @override
  String get dataSourceOff => 'Produktdaten von Open Food Facts';

  @override
  String get cameraUnavailable =>
      'Kamera nicht verfügbar. Prüfe die Berechtigung in den Einstellungen.';

  @override
  String get enterCodeTitle => 'Barcode eingeben';

  @override
  String get enterCodeHint => 'z. B. 4012345678901';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Suchen';

  @override
  String get productAverage => 'Durchschnitt';

  @override
  String get productBuyAgain => 'Wieder kaufen';

  @override
  String get productBought => 'Gekauft';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get productAvailableAt => 'Gibt es bei';

  @override
  String get productHistory => 'Verlauf';

  @override
  String get productNoRatings => 'Noch keine Bewertung. Wie war es?';

  @override
  String get productImageMissing => 'Kein Foto vorhanden';

  @override
  String get back => 'Zurück';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteRatingTitle => 'Bewertung löschen?';

  @override
  String get deleteProductTitle => 'Produkt löschen?';

  @override
  String get deleteProductBody =>
      'Das Produkt und alle Bewertungen werden entfernt.';

  @override
  String nutriScore(String grade) {
    return 'Nutri-Score $grade';
  }

  @override
  String get ratingTitle => 'Neue Bewertung';

  @override
  String get ratingSliderLabel => 'Bewertung von 1 bis 10';

  @override
  String ratingTick(int n) {
    return 'Bewertung $n von 10';
  }

  @override
  String get ratingBuyAgainQuestion => 'Würdest du es wieder kaufen?';

  @override
  String get ratingYes => 'Ja, gerne';

  @override
  String get ratingNo => 'Eher nicht';

  @override
  String get ratingWhere => 'Wo gekauft?';

  @override
  String get ratingLocationFound => 'Standort erkannt';

  @override
  String get ratingOtherStore => 'Anderer Laden';

  @override
  String get ratingNoStore => 'Ohne Laden';

  @override
  String get ratingPrice => 'Preis';

  @override
  String get ratingNote => 'Notiz';

  @override
  String get ratingNoteHint => 'Was war gut, was nicht?';

  @override
  String get optional => '(optional)';

  @override
  String get ratingSave => 'Bewertung speichern';

  @override
  String get score1 => 'Ungenießbar';

  @override
  String get score2 => 'Furchtbar';

  @override
  String get score3 => 'Schlecht';

  @override
  String get score4 => 'Mäßig';

  @override
  String get score5 => 'Geht so';

  @override
  String get score6 => 'Okay';

  @override
  String get score7 => 'Gut';

  @override
  String get score8 => 'Sehr gut';

  @override
  String get score9 => 'Hervorragend';

  @override
  String get score10 => 'Perfekt';

  @override
  String get productFormTitle => 'Produkt anlegen';

  @override
  String get productFormName => 'Name';

  @override
  String get productFormBrand => 'Marke';

  @override
  String get productFormQuantity => 'Menge, z. B. 200 g';

  @override
  String get productFormCategory => 'Kategorie';

  @override
  String get productFormNameRequired => 'Bitte gib einen Namen ein';

  @override
  String get continueToRating => 'Weiter zur Bewertung';

  @override
  String get categoryMeat => 'Wurst & Fleisch';

  @override
  String get categoryCheese => 'Käse';

  @override
  String get categoryDrink => 'Getränke';

  @override
  String get categoryDairy => 'Milchprodukte';

  @override
  String get categoryBakery => 'Brot & Backwaren';

  @override
  String get categorySweets => 'Süßes & Snacks';

  @override
  String get categoryProduce => 'Obst & Gemüse';

  @override
  String get categoryHousehold => 'Haushalt & Drogerie';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get storesTitle => 'Meine Läden';

  @override
  String get storesNearby => 'In deiner Nähe';

  @override
  String get storesAll => 'Alle Läden';

  @override
  String get storesByDistance => 'nach Entfernung';

  @override
  String storesRatedCount(int count) {
    return '$count bewertet';
  }

  @override
  String storesTop(String product) {
    return 'Top: $product';
  }

  @override
  String get storesEmpty =>
      'Noch keine Läden. Lege deinen Supermarkt an, damit du später weißt, wo es was gab.';

  @override
  String get storesSuggestion => 'Vorschlag in der Nähe';

  @override
  String get storesAdd => 'Laden hinzufügen';

  @override
  String get storesAddAction => 'Hinzufügen';

  @override
  String get storesYouAreHere => 'Du bist hier';

  @override
  String get storesMapAttribution => 'Kartendaten © OpenStreetMap-Mitwirkende';

  @override
  String get storesLocationOff => 'Standort nicht verfügbar';

  @override
  String get storeFormName => 'Name des Ladens';

  @override
  String get storeFormAddress => 'Adresse (optional)';

  @override
  String get storeFormUseLocation => 'Aktuellen Standort speichern';

  @override
  String get storeProducts => 'Hier gekauft';

  @override
  String get save => 'Speichern';

  @override
  String get settingsBackup => 'Datensicherung';

  @override
  String get settingsBackupInfo =>
      'Deine Daten werden automatisch über dein Google- bzw. iCloud-Konto gesichert. Zusätzlich kannst du jederzeit eine Sicherungsdatei exportieren.';

  @override
  String get settingsExport => 'Daten exportieren';

  @override
  String get settingsImport => 'Daten importieren';

  @override
  String settingsLastExport(String date) {
    return 'Letzter Export: $date';
  }

  @override
  String get settingsNeverExported => 'Noch nie exportiert';

  @override
  String settingsDbSize(String size) {
    return 'Datenmenge: $size';
  }

  @override
  String get settingsSizeWarning =>
      'Die automatische Sicherung stößt bald an ihre Grenze. Bitte exportiere deine Daten regelmäßig.';

  @override
  String get settingsImportTitle => 'Daten importieren?';

  @override
  String get settingsImportBody =>
      'Alle aktuellen Daten werden durch die Sicherung ersetzt.';

  @override
  String get settingsImportDone => 'Import abgeschlossen';

  @override
  String get settingsImportFailed => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutBody =>
      'Produktdaten und Bilder stammen von Open Food Facts (ODbL), Kartendaten von OpenStreetMap.';

  @override
  String get backupShareText => 'TopFlop-Datensicherung';

  @override
  String get homeAllProducts => 'Alle Produkte';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterReset => 'Zurücksetzen';

  @override
  String get filterRemove => 'Filter entfernen';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte anzeigen',
      one: '1 Produkt anzeigen',
      zero: 'Keine Treffer',
    );
    return '$_temp0';
  }

  @override
  String get filterNoMatchBody => 'Kein Produkt passt zu deinen Filtern.';

  @override
  String get sortTitle => 'Sortierung';

  @override
  String get sortRecent => 'Zuletzt bewertet';

  @override
  String get sortBest => 'Tops zuerst';

  @override
  String get sortWorst => 'Flops zuerst';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get filterScore => 'Bewertung';

  @override
  String get filterAny => 'Egal';

  @override
  String get filterFavoritesOnly => 'Nur Favoriten';

  @override
  String get filterStores => 'Läden';

  @override
  String get filterCategories => 'Kategorien';

  @override
  String filterStoresCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Läden',
      one: '1 Laden',
    );
    return '$_temp0';
  }

  @override
  String filterCategoriesCount(int count) {
    return '$count Kategorien';
  }

  @override
  String get productEditTitle => 'Produkt bearbeiten';

  @override
  String get categoryChoose => 'Kategorie wählen';

  @override
  String get change => 'Ändern';

  @override
  String get ratingEditTitle => 'Bewertung bearbeiten';

  @override
  String get ratingDeleted => 'Bewertung gelöscht';

  @override
  String get undo => 'Rückgängig';

  @override
  String get storeEditTitle => 'Laden bearbeiten';

  @override
  String get storeFormUpdateLocation => 'Standort durch aktuellen ersetzen';

  @override
  String get deleteStoreTitle => 'Laden löschen?';

  @override
  String get deleteStoreBody =>
      'Deine Bewertungen bleiben erhalten, sind danach aber keinem Laden mehr zugeordnet.';
}
