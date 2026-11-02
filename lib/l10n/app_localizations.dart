import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In de, this message translates to:
  /// **'TopFlop'**
  String get appName;

  /// No description provided for @navOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get navOverview;

  /// No description provided for @navScan.
  ///
  /// In de, this message translates to:
  /// **'Scannen'**
  String get navScan;

  /// No description provided for @navStores.
  ///
  /// In de, this message translates to:
  /// **'Läden'**
  String get navStores;

  /// No description provided for @homeTitle.
  ///
  /// In de, this message translates to:
  /// **'Meine Produkte'**
  String get homeTitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Suchen, z. B. Salami'**
  String get homeSearchHint;

  /// No description provided for @homeSearchLabel.
  ///
  /// In de, this message translates to:
  /// **'Produkte durchsuchen'**
  String get homeSearchLabel;

  /// No description provided for @filterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get filterAll;

  /// No description provided for @filterFavorites.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get filterFavorites;

  /// No description provided for @filterBuyAgain.
  ///
  /// In de, this message translates to:
  /// **'Wieder kaufen'**
  String get filterBuyAgain;

  /// No description provided for @homeRecent.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt bewertet'**
  String get homeRecent;

  /// No description provided for @homeResults.
  ///
  /// In de, this message translates to:
  /// **'Treffer'**
  String get homeResults;

  /// No description provided for @productCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Produkt} other{{count} Produkte}}'**
  String productCount(int count);

  /// No description provided for @notBuyAgain.
  ///
  /// In de, this message translates to:
  /// **'Nicht wieder kaufen'**
  String get notBuyAgain;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts bewertet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Scanne dein erstes Produkt im Laden und halte fest, wie es dir geschmeckt hat.'**
  String get homeEmptyBody;

  /// No description provided for @homeNoMatchTitle.
  ///
  /// In de, this message translates to:
  /// **'Nicht gefunden'**
  String get homeNoMatchTitle;

  /// No description provided for @homeNoMatchBody.
  ///
  /// In de, this message translates to:
  /// **'Zu „{query}“ hast du noch nichts gespeichert. Scanne das Produkt, um es zu bewerten.'**
  String homeNoMatchBody(String query);

  /// No description provided for @scanNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt scannen'**
  String get scanNow;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @favorite.
  ///
  /// In de, this message translates to:
  /// **'Favorit'**
  String get favorite;

  /// No description provided for @scanTitle.
  ///
  /// In de, this message translates to:
  /// **'Barcode scannen'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In de, this message translates to:
  /// **'Halte den Barcode in den Rahmen'**
  String get scanHint;

  /// No description provided for @scanEnterCode.
  ///
  /// In de, this message translates to:
  /// **'Code eintippen'**
  String get scanEnterCode;

  /// No description provided for @scanWithoutBarcode.
  ///
  /// In de, this message translates to:
  /// **'Ohne Barcode anlegen'**
  String get scanWithoutBarcode;

  /// No description provided for @scanTorch.
  ///
  /// In de, this message translates to:
  /// **'Taschenlampe'**
  String get scanTorch;

  /// No description provided for @scanClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get scanClose;

  /// No description provided for @scanLooking.
  ///
  /// In de, this message translates to:
  /// **'Suche Produkt …'**
  String get scanLooking;

  /// No description provided for @scanDetected.
  ///
  /// In de, this message translates to:
  /// **'Erkannt · {code}'**
  String scanDetected(String code);

  /// No description provided for @scanAlreadyRated.
  ///
  /// In de, this message translates to:
  /// **'Schon bewertet: {score} von 10'**
  String scanAlreadyRated(int score);

  /// No description provided for @scanLastAgainYes.
  ///
  /// In de, this message translates to:
  /// **'Würdest du wieder kaufen'**
  String get scanLastAgainYes;

  /// No description provided for @scanLastAgainNo.
  ///
  /// In de, this message translates to:
  /// **'Würdest du nicht wieder kaufen'**
  String get scanLastAgainNo;

  /// No description provided for @scanLastAt.
  ///
  /// In de, this message translates to:
  /// **'zuletzt bei {store}'**
  String scanLastAt(String store);

  /// No description provided for @scanNotFoundTitle.
  ///
  /// In de, this message translates to:
  /// **'Produkt unbekannt'**
  String get scanNotFoundTitle;

  /// No description provided for @scanNotFoundBody.
  ///
  /// In de, this message translates to:
  /// **'Zu diesem Barcode gibt es noch keine Daten bei Open Food Facts. Du kannst es selbst anlegen.'**
  String get scanNotFoundBody;

  /// No description provided for @scanOffline.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung. Du kannst das Produkt trotzdem selbst anlegen.'**
  String get scanOffline;

  /// No description provided for @scanCreateProduct.
  ///
  /// In de, this message translates to:
  /// **'Selbst anlegen'**
  String get scanCreateProduct;

  /// No description provided for @scanAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal scannen'**
  String get scanAgain;

  /// No description provided for @details.
  ///
  /// In de, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @rateNew.
  ///
  /// In de, this message translates to:
  /// **'Neu bewerten'**
  String get rateNew;

  /// No description provided for @rate.
  ///
  /// In de, this message translates to:
  /// **'Bewerten'**
  String get rate;

  /// No description provided for @dataSourceOff.
  ///
  /// In de, this message translates to:
  /// **'Produktdaten von Open Food Facts'**
  String get dataSourceOff;

  /// No description provided for @cameraUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Kamera nicht verfügbar. Prüfe die Berechtigung in den Einstellungen.'**
  String get cameraUnavailable;

  /// No description provided for @enterCodeTitle.
  ///
  /// In de, this message translates to:
  /// **'Barcode eingeben'**
  String get enterCodeTitle;

  /// No description provided for @enterCodeHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. 4012345678901'**
  String get enterCodeHint;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @search.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get search;

  /// No description provided for @productAverage.
  ///
  /// In de, this message translates to:
  /// **'Durchschnitt'**
  String get productAverage;

  /// No description provided for @productBuyAgain.
  ///
  /// In de, this message translates to:
  /// **'Wieder kaufen'**
  String get productBuyAgain;

  /// No description provided for @productBought.
  ///
  /// In de, this message translates to:
  /// **'Gekauft'**
  String get productBought;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// No description provided for @productAvailableAt.
  ///
  /// In de, this message translates to:
  /// **'Gibt es bei'**
  String get productAvailableAt;

  /// No description provided for @productHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get productHistory;

  /// No description provided for @productNoRatings.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bewertung. Wie war es?'**
  String get productNoRatings;

  /// No description provided for @productImageMissing.
  ///
  /// In de, this message translates to:
  /// **'Kein Foto vorhanden'**
  String get productImageMissing;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @deleteRatingTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewertung löschen?'**
  String get deleteRatingTitle;

  /// No description provided for @deleteProductTitle.
  ///
  /// In de, this message translates to:
  /// **'Produkt löschen?'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductBody.
  ///
  /// In de, this message translates to:
  /// **'Das Produkt und alle Bewertungen werden entfernt.'**
  String get deleteProductBody;

  /// No description provided for @nutriScore.
  ///
  /// In de, this message translates to:
  /// **'Nutri-Score {grade}'**
  String nutriScore(String grade);

  /// No description provided for @ratingTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Bewertung'**
  String get ratingTitle;

  /// No description provided for @ratingSliderLabel.
  ///
  /// In de, this message translates to:
  /// **'Bewertung von 1 bis 10'**
  String get ratingSliderLabel;

  /// No description provided for @ratingTick.
  ///
  /// In de, this message translates to:
  /// **'Bewertung {n} von 10'**
  String ratingTick(int n);

  /// No description provided for @ratingBuyAgainQuestion.
  ///
  /// In de, this message translates to:
  /// **'Würdest du es wieder kaufen?'**
  String get ratingBuyAgainQuestion;

  /// No description provided for @ratingYes.
  ///
  /// In de, this message translates to:
  /// **'Ja, gerne'**
  String get ratingYes;

  /// No description provided for @ratingNo.
  ///
  /// In de, this message translates to:
  /// **'Eher nicht'**
  String get ratingNo;

  /// No description provided for @ratingWhere.
  ///
  /// In de, this message translates to:
  /// **'Wo gekauft?'**
  String get ratingWhere;

  /// No description provided for @ratingLocationFound.
  ///
  /// In de, this message translates to:
  /// **'Standort erkannt'**
  String get ratingLocationFound;

  /// No description provided for @ratingOtherStore.
  ///
  /// In de, this message translates to:
  /// **'Anderer Laden'**
  String get ratingOtherStore;

  /// No description provided for @ratingNoStore.
  ///
  /// In de, this message translates to:
  /// **'Ohne Laden'**
  String get ratingNoStore;

  /// No description provided for @ratingPrice.
  ///
  /// In de, this message translates to:
  /// **'Preis'**
  String get ratingPrice;

  /// No description provided for @ratingNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get ratingNote;

  /// No description provided for @ratingNoteHint.
  ///
  /// In de, this message translates to:
  /// **'Was war gut, was nicht?'**
  String get ratingNoteHint;

  /// No description provided for @optional.
  ///
  /// In de, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @ratingSave.
  ///
  /// In de, this message translates to:
  /// **'Bewertung speichern'**
  String get ratingSave;

  /// No description provided for @score1.
  ///
  /// In de, this message translates to:
  /// **'Ungenießbar'**
  String get score1;

  /// No description provided for @score2.
  ///
  /// In de, this message translates to:
  /// **'Furchtbar'**
  String get score2;

  /// No description provided for @score3.
  ///
  /// In de, this message translates to:
  /// **'Schlecht'**
  String get score3;

  /// No description provided for @score4.
  ///
  /// In de, this message translates to:
  /// **'Mäßig'**
  String get score4;

  /// No description provided for @score5.
  ///
  /// In de, this message translates to:
  /// **'Geht so'**
  String get score5;

  /// No description provided for @score6.
  ///
  /// In de, this message translates to:
  /// **'Okay'**
  String get score6;

  /// No description provided for @score7.
  ///
  /// In de, this message translates to:
  /// **'Gut'**
  String get score7;

  /// No description provided for @score8.
  ///
  /// In de, this message translates to:
  /// **'Sehr gut'**
  String get score8;

  /// No description provided for @score9.
  ///
  /// In de, this message translates to:
  /// **'Hervorragend'**
  String get score9;

  /// No description provided for @score10.
  ///
  /// In de, this message translates to:
  /// **'Perfekt'**
  String get score10;

  /// No description provided for @productFormTitle.
  ///
  /// In de, this message translates to:
  /// **'Produkt anlegen'**
  String get productFormTitle;

  /// No description provided for @productFormName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get productFormName;

  /// No description provided for @productFormBrand.
  ///
  /// In de, this message translates to:
  /// **'Marke'**
  String get productFormBrand;

  /// No description provided for @productFormQuantity.
  ///
  /// In de, this message translates to:
  /// **'Menge, z. B. 200 g'**
  String get productFormQuantity;

  /// No description provided for @productFormCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get productFormCategory;

  /// No description provided for @productFormNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein'**
  String get productFormNameRequired;

  /// No description provided for @continueToRating.
  ///
  /// In de, this message translates to:
  /// **'Weiter zur Bewertung'**
  String get continueToRating;

  /// No description provided for @categoryMeat.
  ///
  /// In de, this message translates to:
  /// **'Wurst & Fleisch'**
  String get categoryMeat;

  /// No description provided for @categoryCheese.
  ///
  /// In de, this message translates to:
  /// **'Käse'**
  String get categoryCheese;

  /// No description provided for @categoryDrink.
  ///
  /// In de, this message translates to:
  /// **'Getränke'**
  String get categoryDrink;

  /// No description provided for @categoryDairy.
  ///
  /// In de, this message translates to:
  /// **'Milchprodukte'**
  String get categoryDairy;

  /// No description provided for @categoryBakery.
  ///
  /// In de, this message translates to:
  /// **'Brot & Backwaren'**
  String get categoryBakery;

  /// No description provided for @categorySweets.
  ///
  /// In de, this message translates to:
  /// **'Süßes & Snacks'**
  String get categorySweets;

  /// No description provided for @categoryProduce.
  ///
  /// In de, this message translates to:
  /// **'Obst & Gemüse'**
  String get categoryProduce;

  /// No description provided for @categoryHousehold.
  ///
  /// In de, this message translates to:
  /// **'Haushalt & Drogerie'**
  String get categoryHousehold;

  /// No description provided for @categoryOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categoryOther;

  /// No description provided for @storesTitle.
  ///
  /// In de, this message translates to:
  /// **'Meine Läden'**
  String get storesTitle;

  /// No description provided for @storesNearby.
  ///
  /// In de, this message translates to:
  /// **'In deiner Nähe'**
  String get storesNearby;

  /// No description provided for @storesAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Läden'**
  String get storesAll;

  /// No description provided for @storesByDistance.
  ///
  /// In de, this message translates to:
  /// **'nach Entfernung'**
  String get storesByDistance;

  /// No description provided for @storesRatedCount.
  ///
  /// In de, this message translates to:
  /// **'{count} bewertet'**
  String storesRatedCount(int count);

  /// No description provided for @storesTop.
  ///
  /// In de, this message translates to:
  /// **'Top: {product}'**
  String storesTop(String product);

  /// No description provided for @storesEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Läden. Lege deinen Supermarkt an, damit du später weißt, wo es was gab.'**
  String get storesEmpty;

  /// No description provided for @storesSuggestion.
  ///
  /// In de, this message translates to:
  /// **'Vorschlag in der Nähe'**
  String get storesSuggestion;

  /// No description provided for @storesAdd.
  ///
  /// In de, this message translates to:
  /// **'Laden hinzufügen'**
  String get storesAdd;

  /// No description provided for @storesAddAction.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get storesAddAction;

  /// No description provided for @storesYouAreHere.
  ///
  /// In de, this message translates to:
  /// **'Du bist hier'**
  String get storesYouAreHere;

  /// No description provided for @storesMapAttribution.
  ///
  /// In de, this message translates to:
  /// **'Kartendaten © OpenStreetMap-Mitwirkende'**
  String get storesMapAttribution;

  /// No description provided for @storesLocationOff.
  ///
  /// In de, this message translates to:
  /// **'Standort nicht verfügbar'**
  String get storesLocationOff;

  /// No description provided for @storeFormName.
  ///
  /// In de, this message translates to:
  /// **'Name des Ladens'**
  String get storeFormName;

  /// No description provided for @storeFormAddress.
  ///
  /// In de, this message translates to:
  /// **'Adresse (optional)'**
  String get storeFormAddress;

  /// No description provided for @storeFormUseLocation.
  ///
  /// In de, this message translates to:
  /// **'Aktuellen Standort speichern'**
  String get storeFormUseLocation;

  /// No description provided for @storeProducts.
  ///
  /// In de, this message translates to:
  /// **'Hier gekauft'**
  String get storeProducts;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @settingsBackup.
  ///
  /// In de, this message translates to:
  /// **'Datensicherung'**
  String get settingsBackup;

  /// No description provided for @settingsBackupInfo.
  ///
  /// In de, this message translates to:
  /// **'Deine Daten werden automatisch über dein Google- bzw. iCloud-Konto gesichert. Zusätzlich kannst du jederzeit eine Sicherungsdatei exportieren.'**
  String get settingsBackupInfo;

  /// No description provided for @settingsExport.
  ///
  /// In de, this message translates to:
  /// **'Daten exportieren'**
  String get settingsExport;

  /// No description provided for @settingsImport.
  ///
  /// In de, this message translates to:
  /// **'Daten importieren'**
  String get settingsImport;

  /// No description provided for @settingsLastExport.
  ///
  /// In de, this message translates to:
  /// **'Letzter Export: {date}'**
  String settingsLastExport(String date);

  /// No description provided for @settingsNeverExported.
  ///
  /// In de, this message translates to:
  /// **'Noch nie exportiert'**
  String get settingsNeverExported;

  /// No description provided for @settingsDbSize.
  ///
  /// In de, this message translates to:
  /// **'Datenmenge: {size}'**
  String settingsDbSize(String size);

  /// No description provided for @settingsSizeWarning.
  ///
  /// In de, this message translates to:
  /// **'Die automatische Sicherung stößt bald an ihre Grenze. Bitte exportiere deine Daten regelmäßig.'**
  String get settingsSizeWarning;

  /// No description provided for @settingsImportTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten importieren?'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportBody.
  ///
  /// In de, this message translates to:
  /// **'Alle aktuellen Daten werden durch die Sicherung ersetzt.'**
  String get settingsImportBody;

  /// No description provided for @settingsImportDone.
  ///
  /// In de, this message translates to:
  /// **'Import abgeschlossen'**
  String get settingsImportDone;

  /// No description provided for @settingsImportFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Datei konnte nicht gelesen werden.'**
  String get settingsImportFailed;

  /// No description provided for @settingsAbout.
  ///
  /// In de, this message translates to:
  /// **'Über'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In de, this message translates to:
  /// **'Produktdaten und Bilder stammen von Open Food Facts (ODbL), Kartendaten von OpenStreetMap.'**
  String get settingsAboutBody;

  /// No description provided for @backupShareText.
  ///
  /// In de, this message translates to:
  /// **'TopFlop-Datensicherung'**
  String get backupShareText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
