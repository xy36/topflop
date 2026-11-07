// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'TopFlop';

  @override
  String get navOverview => 'Panoramica';

  @override
  String get navScan => 'Scansiona';

  @override
  String get navStores => 'Negozi';

  @override
  String get homeTitle => 'I miei prodotti';

  @override
  String get homeSearchHint => 'Cerca, ad es. salame';

  @override
  String get homeSearchLabel => 'Cerca prodotti';

  @override
  String get filterAll => 'Tutti i negozi';

  @override
  String get filterFavorites => 'Preferiti';

  @override
  String get filterBuyAgain => 'Da ricomprare';

  @override
  String get homeRecent => 'Valutati di recente';

  @override
  String get homeResults => 'Risultati';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prodotti',
      one: '1 prodotto',
    );
    return '$_temp0';
  }

  @override
  String get notBuyAgain => 'Non lo ricomprerei';

  @override
  String get homeEmptyTitle => 'Ancora nessuna valutazione';

  @override
  String get homeEmptyBody =>
      'Scansiona il tuo primo prodotto al supermercato e annota quanto ti è piaciuto.';

  @override
  String get homeNoMatchTitle => 'Non trovato';

  @override
  String homeNoMatchBody(String query) {
    return 'Non hai ancora salvato nulla per «$query». Scansiona il prodotto per valutarlo.';
  }

  @override
  String get scanNow => 'Scansiona';

  @override
  String get settings => 'Impostazioni';

  @override
  String get favorite => 'Preferito';

  @override
  String get scanTitle => 'Scansiona codice a barre';

  @override
  String get scanHint => 'Inquadra il codice a barre nella cornice';

  @override
  String get scanEnterCode => 'Digita codice';

  @override
  String get scanWithoutBarcode => 'Aggiungi senza codice a barre';

  @override
  String get scanTorch => 'Torcia';

  @override
  String get scanClose => 'Chiudi';

  @override
  String get scanLooking => 'Ricerca del prodotto …';

  @override
  String scanDetected(String code) {
    return 'Rilevato · $code';
  }

  @override
  String scanAlreadyRated(int score) {
    return 'Già valutato: $score su 10';
  }

  @override
  String get scanLastAgainYes => 'Lo ricompreresti';

  @override
  String get scanLastAgainNo => 'Non lo ricompreresti';

  @override
  String scanLastAt(String store) {
    return 'l’ultima volta da $store';
  }

  @override
  String get scanNotFoundTitle => 'Prodotto sconosciuto';

  @override
  String get scanNotFoundBody =>
      'Open Food Facts non ha ancora dati per questo codice a barre. Puoi aggiungerlo tu.';

  @override
  String get scanOffline =>
      'Nessuna connessione. Puoi comunque aggiungere il prodotto tu.';

  @override
  String get scanCreateProduct => 'Aggiungi manualmente';

  @override
  String get scanAgain => 'Scansiona di nuovo';

  @override
  String get details => 'Dettagli';

  @override
  String get rate => 'Valuta';

  @override
  String get dataSourceOff => 'Dati del prodotto da Open Food Facts';

  @override
  String get cameraUnavailable =>
      'Fotocamera non disponibile. Controlla l’autorizzazione nelle impostazioni.';

  @override
  String get enterCodeTitle => 'Inserisci codice a barre';

  @override
  String get enterCodeHint => 'ad es. 4012345678901';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Cerca';

  @override
  String get productBuyAgain => 'Da ricomprare';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get productAvailableAt => 'Disponibile da';

  @override
  String get productNoRatings => 'Ancora nessuna valutazione. Com’era?';

  @override
  String get productImageMissing => 'Nessuna foto disponibile';

  @override
  String get back => 'Indietro';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteProductTitle => 'Eliminare il prodotto?';

  @override
  String get deleteProductBody =>
      'Il prodotto e tutte le sue valutazioni verranno rimossi.';

  @override
  String nutriScore(String grade) {
    return 'Nutri-Score $grade';
  }

  @override
  String get ratingTitle => 'Nuova valutazione';

  @override
  String get ratingSliderLabel => 'Valutazione da 1 a 10';

  @override
  String ratingTick(int n) {
    return 'Valutazione $n su 10';
  }

  @override
  String get ratingBuyAgainQuestion => 'Lo ricompreresti?';

  @override
  String get ratingYes => 'Sì, volentieri';

  @override
  String get ratingNo => 'Meglio di no';

  @override
  String get ratingWhere => 'Dove si trova?';

  @override
  String get ratingLastStores => 'Come l’ultima volta';

  @override
  String get ratingOtherStore => 'Altro negozio';

  @override
  String get ratingPrice => 'Prezzo';

  @override
  String get ratingNote => 'Nota';

  @override
  String get ratingNoteHint => 'Cosa ti è piaciuto e cosa no?';

  @override
  String get optional => '(facoltativo)';

  @override
  String get ratingSave => 'Salva valutazione';

  @override
  String get score1 => 'Immangiabile';

  @override
  String get score2 => 'Orribile';

  @override
  String get score3 => 'Cattivo';

  @override
  String get score4 => 'Scarso';

  @override
  String get score5 => 'Così così';

  @override
  String get score6 => 'Discreto';

  @override
  String get score7 => 'Buono';

  @override
  String get score8 => 'Molto buono';

  @override
  String get score9 => 'Eccellente';

  @override
  String get score10 => 'Perfetto';

  @override
  String get productFormTitle => 'Aggiungi prodotto';

  @override
  String get productFormName => 'Nome';

  @override
  String get productFormBrand => 'Marca';

  @override
  String get productFormQuantity => 'Quantità, ad es. 200 g';

  @override
  String get productFormCategory => 'Categoria';

  @override
  String get productFormNameRequired => 'Inserisci un nome';

  @override
  String get continueToRating => 'Continua alla valutazione';

  @override
  String get categoryMeat => 'Carne e salumi';

  @override
  String get categoryCheese => 'Formaggi';

  @override
  String get categoryDrink => 'Bevande';

  @override
  String get categoryDairy => 'Latticini';

  @override
  String get categoryBakery => 'Pane e prodotti da forno';

  @override
  String get categorySweets => 'Dolci e snack';

  @override
  String get categoryProduce => 'Frutta e verdura';

  @override
  String get categoryHousehold => 'Casa e igiene';

  @override
  String get categoryOther => 'Altro';

  @override
  String get storesTitle => 'I miei negozi';

  @override
  String get storesAll => 'Tutti i negozi';

  @override
  String storesRatedCount(int count) {
    return '$count valutati';
  }

  @override
  String storesTop(String product) {
    return 'Top: $product';
  }

  @override
  String get storesEmpty =>
      'Ancora nessun negozio. Aggiungi il tuo supermercato per ricordarti dove hai trovato cosa.';

  @override
  String get storesAdd => 'Aggiungi negozio';

  @override
  String get storeFormName => 'Negozio / catena';

  @override
  String get storeProducts => 'Disponibile qui';

  @override
  String get save => 'Salva';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupInfo =>
      'I tuoi dati vengono salvati automaticamente tramite il tuo account Google o iCloud. Puoi anche esportare un file di backup in qualsiasi momento.';

  @override
  String get settingsExport => 'Esporta dati';

  @override
  String get settingsImport => 'Importa dati';

  @override
  String settingsLastExport(String date) {
    return 'Ultima esportazione: $date';
  }

  @override
  String get settingsNeverExported => 'Mai esportato';

  @override
  String settingsDbSize(String size) {
    return 'Dimensione dati: $size';
  }

  @override
  String get settingsSizeWarning =>
      'Il backup automatico è vicino al limite. Esporta i tuoi dati regolarmente.';

  @override
  String get settingsImportTitle => 'Importare i dati?';

  @override
  String get settingsImportBody =>
      'Tutti i dati attuali verranno sostituiti dal backup.';

  @override
  String get settingsImportDone => 'Importazione completata';

  @override
  String get settingsImportFailed => 'Impossibile leggere il file.';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsAboutBody =>
      'Dati e immagini dei prodotti provengono da Open Food Facts (ODbL).';

  @override
  String get backupShareText => 'Backup di TopFlop';

  @override
  String get homeAllProducts => 'Tutti i prodotti';

  @override
  String get filterTitle => 'Filtri';

  @override
  String get filterReset => 'Reimposta';

  @override
  String get filterRemove => 'Rimuovi filtro';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostra $count prodotti',
      one: 'Mostra 1 prodotto',
      zero: 'Nessun risultato',
    );
    return '$_temp0';
  }

  @override
  String get filterNoMatchBody => 'Nessun prodotto corrisponde ai tuoi filtri.';

  @override
  String get sortTitle => 'Ordina per';

  @override
  String get sortRecent => 'Valutati di recente';

  @override
  String get sortBest => 'Prima i top';

  @override
  String get sortWorst => 'Prima i flop';

  @override
  String get sortName => 'Nome A–Z';

  @override
  String get filterScore => 'Valutazione';

  @override
  String get filterAny => 'Indifferente';

  @override
  String get filterFavoritesOnly => 'Solo preferiti';

  @override
  String get filterStores => 'Negozi';

  @override
  String get filterCategories => 'Categorie';

  @override
  String filterCategoriesCount(int count) {
    return '$count categorie';
  }

  @override
  String get productEditTitle => 'Modifica prodotto';

  @override
  String get categoryChoose => 'Scegli categoria';

  @override
  String get change => 'Cambia';

  @override
  String get storeFormNameHint => 'ad es. Esselunga';

  @override
  String storeFormExists(String name) {
    return '$name esiste già e verrà selezionato';
  }

  @override
  String get ratingChange => 'Modifica valutazione';

  @override
  String get productScore => 'Valutazione';

  @override
  String productRatedOn(String date) {
    return 'Valutato il $date';
  }

  @override
  String get productYourNote => 'La tua nota';

  @override
  String get ratingWhereHint => 'Scegli tutti i negozi che vuoi';

  @override
  String get ratingEditTitle => 'Modifica valutazione';

  @override
  String get storeEditTitle => 'Modifica negozio';

  @override
  String get deleteStoreTitle => 'Eliminare il negozio?';

  @override
  String get deleteStoreBody =>
      'Il negozio verrà eliminato. Le tue valutazioni restano.';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';
}
