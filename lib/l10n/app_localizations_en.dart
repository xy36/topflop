// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TopFlop';

  @override
  String get navOverview => 'Overview';

  @override
  String get navScan => 'Scan';

  @override
  String get navStores => 'Stores';

  @override
  String get homeTitle => 'My products';

  @override
  String get homeSearchHint => 'Search, e.g. salami';

  @override
  String get homeSearchLabel => 'Search products';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get filterBuyAgain => 'Buy again';

  @override
  String get homeRecent => 'Recently rated';

  @override
  String get homeResults => 'Results';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get notBuyAgain => 'Wouldn\'t buy again';

  @override
  String get homeEmptyTitle => 'Nothing rated yet';

  @override
  String get homeEmptyBody =>
      'Scan your first product in the store and note how much you liked it.';

  @override
  String get homeNoMatchTitle => 'Not found';

  @override
  String homeNoMatchBody(String query) {
    return 'You haven\'t saved anything for “$query” yet. Scan the product to rate it.';
  }

  @override
  String get scanNow => 'Scan now';

  @override
  String get settings => 'Settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get scanTitle => 'Scan barcode';

  @override
  String get scanHint => 'Hold the barcode inside the frame';

  @override
  String get scanEnterCode => 'Type code';

  @override
  String get scanWithoutBarcode => 'Add without barcode';

  @override
  String get scanTorch => 'Flashlight';

  @override
  String get scanClose => 'Close';

  @override
  String get scanLooking => 'Looking up product …';

  @override
  String scanDetected(String code) {
    return 'Detected · $code';
  }

  @override
  String scanAlreadyRated(int score) {
    return 'Already rated: $score out of 10';
  }

  @override
  String get scanLastAgainYes => 'You\'d buy it again';

  @override
  String get scanLastAgainNo => 'You wouldn\'t buy it again';

  @override
  String scanLastAt(String store) {
    return 'last at $store';
  }

  @override
  String get scanNotFoundTitle => 'Unknown product';

  @override
  String get scanNotFoundBody =>
      'Open Food Facts has no data for this barcode yet. You can add it yourself.';

  @override
  String get scanOffline =>
      'No connection. You can still add the product yourself.';

  @override
  String get scanCreateProduct => 'Add manually';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get details => 'Details';

  @override
  String get rateNew => 'Rate again';

  @override
  String get rate => 'Rate';

  @override
  String get dataSourceOff => 'Product data from Open Food Facts';

  @override
  String get cameraUnavailable =>
      'Camera unavailable. Check the permission in your settings.';

  @override
  String get enterCodeTitle => 'Enter barcode';

  @override
  String get enterCodeHint => 'e.g. 4012345678901';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Search';

  @override
  String get productAverage => 'Average';

  @override
  String get productBuyAgain => 'Buy again';

  @override
  String get productBought => 'Bought';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get productAvailableAt => 'Available at';

  @override
  String get productHistory => 'History';

  @override
  String get productNoRatings => 'No rating yet. How was it?';

  @override
  String get productImageMissing => 'No photo available';

  @override
  String get back => 'Back';

  @override
  String get delete => 'Delete';

  @override
  String get deleteRatingTitle => 'Delete rating?';

  @override
  String get deleteProductTitle => 'Delete product?';

  @override
  String get deleteProductBody =>
      'The product and all its ratings will be removed.';

  @override
  String nutriScore(String grade) {
    return 'Nutri-Score $grade';
  }

  @override
  String get ratingTitle => 'New rating';

  @override
  String get ratingSliderLabel => 'Rating from 1 to 10';

  @override
  String ratingTick(int n) {
    return 'Rating $n out of 10';
  }

  @override
  String get ratingBuyAgainQuestion => 'Would you buy it again?';

  @override
  String get ratingYes => 'Yes, gladly';

  @override
  String get ratingNo => 'Rather not';

  @override
  String get ratingWhere => 'Where did you buy it?';

  @override
  String get ratingLocationFound => 'Location found';

  @override
  String get ratingOtherStore => 'Other store';

  @override
  String get ratingNoStore => 'No store';

  @override
  String get ratingPrice => 'Price';

  @override
  String get ratingNote => 'Note';

  @override
  String get ratingNoteHint => 'What was good, what wasn\'t?';

  @override
  String get optional => '(optional)';

  @override
  String get ratingSave => 'Save rating';

  @override
  String get score1 => 'Inedible';

  @override
  String get score2 => 'Awful';

  @override
  String get score3 => 'Bad';

  @override
  String get score4 => 'Poor';

  @override
  String get score5 => 'Meh';

  @override
  String get score6 => 'Okay';

  @override
  String get score7 => 'Good';

  @override
  String get score8 => 'Very good';

  @override
  String get score9 => 'Excellent';

  @override
  String get score10 => 'Perfect';

  @override
  String get productFormTitle => 'Add product';

  @override
  String get productFormName => 'Name';

  @override
  String get productFormBrand => 'Brand';

  @override
  String get productFormQuantity => 'Quantity, e.g. 200 g';

  @override
  String get productFormCategory => 'Category';

  @override
  String get productFormNameRequired => 'Please enter a name';

  @override
  String get continueToRating => 'Continue to rating';

  @override
  String get categoryMeat => 'Meat & sausage';

  @override
  String get categoryCheese => 'Cheese';

  @override
  String get categoryDrink => 'Drinks';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryBakery => 'Bread & bakery';

  @override
  String get categorySweets => 'Sweets & snacks';

  @override
  String get categoryProduce => 'Fruit & vegetables';

  @override
  String get categoryHousehold => 'Household & toiletries';

  @override
  String get categoryOther => 'Other';

  @override
  String get storesTitle => 'My stores';

  @override
  String get storesNearby => 'Near you';

  @override
  String get storesAll => 'All stores';

  @override
  String get storesByDistance => 'by distance';

  @override
  String storesRatedCount(int count) {
    return '$count rated';
  }

  @override
  String storesTop(String product) {
    return 'Top: $product';
  }

  @override
  String get storesEmpty =>
      'No stores yet. Add your supermarket so you remember where you found what.';

  @override
  String get storesSuggestion => 'Suggestion nearby';

  @override
  String get storesAdd => 'Add store';

  @override
  String get storesAddAction => 'Add';

  @override
  String get storesYouAreHere => 'You are here';

  @override
  String get storesMapAttribution => 'Map data © OpenStreetMap contributors';

  @override
  String get storesLocationOff => 'Location unavailable';

  @override
  String get storeFormName => 'Store name';

  @override
  String get storeFormAddress => 'Address (optional)';

  @override
  String get storeFormUseLocation => 'Save current location';

  @override
  String get storeProducts => 'Bought here';

  @override
  String get save => 'Save';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupInfo =>
      'Your data is backed up automatically through your Google or iCloud account. You can also export a backup file at any time.';

  @override
  String get settingsExport => 'Export data';

  @override
  String get settingsImport => 'Import data';

  @override
  String settingsLastExport(String date) {
    return 'Last export: $date';
  }

  @override
  String get settingsNeverExported => 'Never exported';

  @override
  String settingsDbSize(String size) {
    return 'Data size: $size';
  }

  @override
  String get settingsSizeWarning =>
      'The automatic backup is close to its limit. Please export your data regularly.';

  @override
  String get settingsImportTitle => 'Import data?';

  @override
  String get settingsImportBody =>
      'All current data will be replaced by the backup.';

  @override
  String get settingsImportDone => 'Import finished';

  @override
  String get settingsImportFailed => 'The file could not be read.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutBody =>
      'Product data and images come from Open Food Facts (ODbL), map data from OpenStreetMap.';

  @override
  String get backupShareText => 'TopFlop backup';
}
