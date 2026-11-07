// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'TopFlop';

  @override
  String get navOverview => 'Overzicht';

  @override
  String get navScan => 'Scannen';

  @override
  String get navStores => 'Winkels';

  @override
  String get homeTitle => 'Mijn producten';

  @override
  String get homeSearchHint => 'Zoeken, bijv. salami';

  @override
  String get homeSearchLabel => 'Producten zoeken';

  @override
  String get filterAll => 'Alle winkels';

  @override
  String get filterFavorites => 'Favorieten';

  @override
  String get filterBuyAgain => 'Weer kopen';

  @override
  String get homeRecent => 'Recent beoordeeld';

  @override
  String get homeResults => 'Resultaten';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count producten',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get notBuyAgain => 'Niet opnieuw kopen';

  @override
  String get homeEmptyTitle => 'Nog niets beoordeeld';

  @override
  String get homeEmptyBody =>
      'Scan je eerste product in de winkel en noteer hoe lekker je het vond.';

  @override
  String get homeNoMatchTitle => 'Niet gevonden';

  @override
  String homeNoMatchBody(String query) {
    return 'Je hebt nog niets opgeslagen voor ‘$query’. Scan het product om het te beoordelen.';
  }

  @override
  String get scanNow => 'Nu scannen';

  @override
  String get settings => 'Instellingen';

  @override
  String get favorite => 'Favoriet';

  @override
  String get scanTitle => 'Barcode scannen';

  @override
  String get scanHint => 'Houd de barcode binnen het kader';

  @override
  String get scanEnterCode => 'Code typen';

  @override
  String get scanWithoutBarcode => 'Toevoegen zonder barcode';

  @override
  String get scanTorch => 'Zaklamp';

  @override
  String get scanClose => 'Sluiten';

  @override
  String get scanLooking => 'Product opzoeken …';

  @override
  String scanDetected(String code) {
    return 'Herkend · $code';
  }

  @override
  String scanAlreadyRated(int score) {
    return 'Al beoordeeld: $score van 10';
  }

  @override
  String get scanLastAgainYes => 'Je zou het weer kopen';

  @override
  String get scanLastAgainNo => 'Je zou het niet weer kopen';

  @override
  String scanLastAt(String store) {
    return 'laatst bij $store';
  }

  @override
  String get scanNotFoundTitle => 'Onbekend product';

  @override
  String get scanNotFoundBody =>
      'Open Food Facts heeft nog geen gegevens voor deze barcode. Je kunt het zelf toevoegen.';

  @override
  String get scanOffline =>
      'Geen verbinding. Je kunt het product toch zelf toevoegen.';

  @override
  String get scanCreateProduct => 'Handmatig toevoegen';

  @override
  String get scanAgain => 'Opnieuw scannen';

  @override
  String get details => 'Details';

  @override
  String get rate => 'Beoordelen';

  @override
  String get dataSourceOff => 'Productgegevens van Open Food Facts';

  @override
  String get cameraUnavailable =>
      'Camera niet beschikbaar. Controleer de toestemming in je instellingen.';

  @override
  String get enterCodeTitle => 'Barcode invoeren';

  @override
  String get enterCodeHint => 'bijv. 4012345678901';

  @override
  String get cancel => 'Annuleren';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Zoeken';

  @override
  String get productBuyAgain => 'Weer kopen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get productAvailableAt => 'Verkrijgbaar bij';

  @override
  String get productNoRatings => 'Nog geen beoordeling. Hoe was het?';

  @override
  String get productImageMissing => 'Geen foto beschikbaar';

  @override
  String get back => 'Terug';

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleteProductTitle => 'Product verwijderen?';

  @override
  String get deleteProductBody =>
      'Het product en al zijn beoordelingen worden verwijderd.';

  @override
  String nutriScore(String grade) {
    return 'Nutri-Score $grade';
  }

  @override
  String get ratingTitle => 'Nieuwe beoordeling';

  @override
  String get ratingSliderLabel => 'Beoordeling van 1 tot 10';

  @override
  String ratingTick(int n) {
    return 'Beoordeling $n van 10';
  }

  @override
  String get ratingBuyAgainQuestion => 'Zou je het weer kopen?';

  @override
  String get ratingYes => 'Ja, graag';

  @override
  String get ratingNo => 'Liever niet';

  @override
  String get ratingWhere => 'Waar is het te koop?';

  @override
  String get ratingLastStores => 'Zoals de vorige keer';

  @override
  String get ratingOtherStore => 'Andere winkel';

  @override
  String get ratingPrice => 'Prijs';

  @override
  String get ratingNote => 'Notitie';

  @override
  String get ratingNoteHint => 'Wat was goed, wat niet?';

  @override
  String get optional => '(optioneel)';

  @override
  String get ratingSave => 'Beoordeling opslaan';

  @override
  String get score1 => 'Oneetbaar';

  @override
  String get score2 => 'Vreselijk';

  @override
  String get score3 => 'Slecht';

  @override
  String get score4 => 'Matig';

  @override
  String get score5 => 'Gaat wel';

  @override
  String get score6 => 'Oké';

  @override
  String get score7 => 'Goed';

  @override
  String get score8 => 'Heel goed';

  @override
  String get score9 => 'Uitstekend';

  @override
  String get score10 => 'Perfect';

  @override
  String get productFormTitle => 'Product toevoegen';

  @override
  String get productFormName => 'Naam';

  @override
  String get productFormBrand => 'Merk';

  @override
  String get productFormQuantity => 'Hoeveelheid, bijv. 200 g';

  @override
  String get productFormCategory => 'Categorie';

  @override
  String get productFormNameRequired => 'Vul een naam in';

  @override
  String get continueToRating => 'Verder naar beoordeling';

  @override
  String get categoryMeat => 'Vlees & vleeswaren';

  @override
  String get categoryCheese => 'Kaas';

  @override
  String get categoryDrink => 'Dranken';

  @override
  String get categoryDairy => 'Zuivel';

  @override
  String get categoryBakery => 'Brood & gebak';

  @override
  String get categorySweets => 'Snoep & snacks';

  @override
  String get categoryProduce => 'Groente & fruit';

  @override
  String get categoryHousehold => 'Huishouden & verzorging';

  @override
  String get categoryOther => 'Overig';

  @override
  String get storesTitle => 'Mijn winkels';

  @override
  String get storesAll => 'Alle winkels';

  @override
  String storesRatedCount(int count) {
    return '$count beoordeeld';
  }

  @override
  String storesTop(String product) {
    return 'Top: $product';
  }

  @override
  String get storesEmpty =>
      'Nog geen winkels. Voeg je supermarkt toe, zodat je weet waar je wat gevonden hebt.';

  @override
  String get storesAdd => 'Winkel toevoegen';

  @override
  String get storeFormName => 'Winkel / keten';

  @override
  String get storeProducts => 'Hier verkrijgbaar';

  @override
  String get save => 'Opslaan';

  @override
  String get settingsBackup => 'Back-up';

  @override
  String get settingsBackupInfo =>
      'Je gegevens worden automatisch via je Google- of iCloud-account bewaard. Je kunt ook op elk moment een back-upbestand exporteren.';

  @override
  String get settingsExport => 'Gegevens exporteren';

  @override
  String get settingsImport => 'Gegevens importeren';

  @override
  String settingsLastExport(String date) {
    return 'Laatste export: $date';
  }

  @override
  String get settingsNeverExported => 'Nooit geëxporteerd';

  @override
  String settingsDbSize(String size) {
    return 'Gegevensgrootte: $size';
  }

  @override
  String get settingsSizeWarning =>
      'De automatische back-up nadert zijn limiet. Exporteer je gegevens regelmatig.';

  @override
  String get settingsImportTitle => 'Gegevens importeren?';

  @override
  String get settingsImportBody =>
      'Alle huidige gegevens worden vervangen door de back-up.';

  @override
  String get settingsImportDone => 'Import voltooid';

  @override
  String get settingsImportFailed => 'Het bestand kon niet worden gelezen.';

  @override
  String get settingsAbout => 'Over';

  @override
  String get settingsAboutBody =>
      'Productgegevens en afbeeldingen komen van Open Food Facts (ODbL).';

  @override
  String get backupShareText => 'TopFlop-back-up';

  @override
  String get homeAllProducts => 'Alle producten';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterReset => 'Herstellen';

  @override
  String get filterRemove => 'Filter verwijderen';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count producten tonen',
      one: '1 product tonen',
      zero: 'Geen resultaten',
    );
    return '$_temp0';
  }

  @override
  String get filterNoMatchBody => 'Geen product past bij je filters.';

  @override
  String get sortTitle => 'Sorteren op';

  @override
  String get sortRecent => 'Recent beoordeeld';

  @override
  String get sortBest => 'Tops eerst';

  @override
  String get sortWorst => 'Flops eerst';

  @override
  String get sortName => 'Naam A–Z';

  @override
  String get filterScore => 'Beoordeling';

  @override
  String get filterAny => 'Maakt niet uit';

  @override
  String get filterFavoritesOnly => 'Alleen favorieten';

  @override
  String get filterStores => 'Winkels';

  @override
  String get filterCategories => 'Categorieën';

  @override
  String filterCategoriesCount(int count) {
    return '$count categorieën';
  }

  @override
  String get productEditTitle => 'Product bewerken';

  @override
  String get categoryChoose => 'Categorie kiezen';

  @override
  String get change => 'Wijzigen';

  @override
  String get storeFormNameHint => 'bijv. Albert Heijn';

  @override
  String storeFormExists(String name) {
    return '$name bestaat al en wordt geselecteerd';
  }

  @override
  String get ratingChange => 'Beoordeling wijzigen';

  @override
  String get productScore => 'Beoordeling';

  @override
  String productRatedOn(String date) {
    return 'Beoordeeld op $date';
  }

  @override
  String get productYourNote => 'Jouw notitie';

  @override
  String get ratingWhereHint => 'Kies zoveel winkels als je wilt';

  @override
  String get ratingEditTitle => 'Beoordeling bewerken';

  @override
  String get storeEditTitle => 'Winkel bewerken';

  @override
  String get deleteStoreTitle => 'Winkel verwijderen?';

  @override
  String get deleteStoreBody =>
      'De winkel wordt verwijderd. Je beoordelingen blijven bewaard.';

  @override
  String get settingsAppearance => 'Weergave';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';
}
