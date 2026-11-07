// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'TopFlop';

  @override
  String get navOverview => 'Resumen';

  @override
  String get navScan => 'Escanear';

  @override
  String get navStores => 'Tiendas';

  @override
  String get homeTitle => 'Mis productos';

  @override
  String get homeSearchHint => 'Buscar, p. ej. salami';

  @override
  String get homeSearchLabel => 'Buscar productos';

  @override
  String get filterAll => 'Todas las tiendas';

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get filterBuyAgain => 'Volver a comprar';

  @override
  String get homeRecent => 'Valorados recientemente';

  @override
  String get homeResults => 'Resultados';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String get notBuyAgain => 'No lo volvería a comprar';

  @override
  String get homeEmptyTitle => 'Aún no has valorado nada';

  @override
  String get homeEmptyBody =>
      'Escanea tu primer producto en la tienda y anota cuánto te ha gustado.';

  @override
  String get homeNoMatchTitle => 'No encontrado';

  @override
  String homeNoMatchBody(String query) {
    return 'Aún no has guardado nada para «$query». Escanea el producto para valorarlo.';
  }

  @override
  String get scanNow => 'Escanear';

  @override
  String get settings => 'Ajustes';

  @override
  String get favorite => 'Favorito';

  @override
  String get scanTitle => 'Escanear código de barras';

  @override
  String get scanHint => 'Coloca el código de barras dentro del marco';

  @override
  String get scanEnterCode => 'Escribir código';

  @override
  String get scanWithoutBarcode => 'Añadir sin código de barras';

  @override
  String get scanTorch => 'Linterna';

  @override
  String get scanClose => 'Cerrar';

  @override
  String get scanLooking => 'Buscando producto …';

  @override
  String scanDetected(String code) {
    return 'Detectado · $code';
  }

  @override
  String scanAlreadyRated(int score) {
    return 'Ya valorado: $score de 10';
  }

  @override
  String get scanLastAgainYes => 'Lo volverías a comprar';

  @override
  String get scanLastAgainNo => 'No lo volverías a comprar';

  @override
  String scanLastAt(String store) {
    return 'la última vez en $store';
  }

  @override
  String get scanNotFoundTitle => 'Producto desconocido';

  @override
  String get scanNotFoundBody =>
      'Open Food Facts aún no tiene datos de este código de barras. Puedes añadirlo tú mismo.';

  @override
  String get scanOffline =>
      'Sin conexión. Aun así puedes añadir el producto tú mismo.';

  @override
  String get scanCreateProduct => 'Añadir manualmente';

  @override
  String get scanAgain => 'Escanear de nuevo';

  @override
  String get details => 'Detalles';

  @override
  String get rate => 'Valorar';

  @override
  String get dataSourceOff => 'Datos del producto de Open Food Facts';

  @override
  String get cameraUnavailable =>
      'Cámara no disponible. Revisa el permiso en los ajustes.';

  @override
  String get enterCodeTitle => 'Introducir código de barras';

  @override
  String get enterCodeHint => 'p. ej. 4012345678901';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Buscar';

  @override
  String get productBuyAgain => 'Volver a comprar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get productAvailableAt => 'Disponible en';

  @override
  String get productNoRatings => 'Aún sin valoración. ¿Qué tal estaba?';

  @override
  String get productImageMissing => 'No hay foto disponible';

  @override
  String get back => 'Atrás';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteProductTitle => '¿Eliminar producto?';

  @override
  String get deleteProductBody =>
      'Se eliminarán el producto y todas sus valoraciones.';

  @override
  String nutriScore(String grade) {
    return 'Nutri-Score $grade';
  }

  @override
  String get ratingTitle => 'Nueva valoración';

  @override
  String get ratingSliderLabel => 'Valoración del 1 al 10';

  @override
  String ratingTick(int n) {
    return 'Valoración $n de 10';
  }

  @override
  String get ratingBuyAgainQuestion => '¿Lo volverías a comprar?';

  @override
  String get ratingYes => 'Sí, claro';

  @override
  String get ratingNo => 'Mejor no';

  @override
  String get ratingWhere => '¿Dónde lo encuentras?';

  @override
  String get ratingLastStores => 'Como la última vez';

  @override
  String get ratingOtherStore => 'Otra tienda';

  @override
  String get ratingPrice => 'Precio';

  @override
  String get ratingNote => 'Nota';

  @override
  String get ratingNoteHint => '¿Qué estuvo bien y qué no?';

  @override
  String get optional => '(opcional)';

  @override
  String get ratingSave => 'Guardar valoración';

  @override
  String get score1 => 'Incomible';

  @override
  String get score2 => 'Horrible';

  @override
  String get score3 => 'Malo';

  @override
  String get score4 => 'Flojo';

  @override
  String get score5 => 'Regular';

  @override
  String get score6 => 'Aceptable';

  @override
  String get score7 => 'Bueno';

  @override
  String get score8 => 'Muy bueno';

  @override
  String get score9 => 'Excelente';

  @override
  String get score10 => 'Perfecto';

  @override
  String get productFormTitle => 'Añadir producto';

  @override
  String get productFormName => 'Nombre';

  @override
  String get productFormBrand => 'Marca';

  @override
  String get productFormQuantity => 'Cantidad, p. ej. 200 g';

  @override
  String get productFormCategory => 'Categoría';

  @override
  String get productFormNameRequired => 'Introduce un nombre';

  @override
  String get continueToRating => 'Continuar a la valoración';

  @override
  String get categoryMeat => 'Carne y embutidos';

  @override
  String get categoryCheese => 'Queso';

  @override
  String get categoryDrink => 'Bebidas';

  @override
  String get categoryDairy => 'Lácteos';

  @override
  String get categoryBakery => 'Pan y bollería';

  @override
  String get categorySweets => 'Dulces y snacks';

  @override
  String get categoryProduce => 'Fruta y verdura';

  @override
  String get categoryHousehold => 'Hogar e higiene';

  @override
  String get categoryOther => 'Otros';

  @override
  String get storesTitle => 'Mis tiendas';

  @override
  String get storesAll => 'Todas las tiendas';

  @override
  String storesRatedCount(int count) {
    return '$count valorados';
  }

  @override
  String storesTop(String product) {
    return 'Top: $product';
  }

  @override
  String get storesEmpty =>
      'Aún no hay tiendas. Añade tu supermercado para recordar dónde encontraste cada cosa.';

  @override
  String get storesAdd => 'Añadir tienda';

  @override
  String get storeFormName => 'Tienda / cadena';

  @override
  String get storeProducts => 'Disponible aquí';

  @override
  String get save => 'Guardar';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsBackupInfo =>
      'Tus datos se guardan automáticamente en tu cuenta de Google o iCloud. También puedes exportar un archivo de copia de seguridad cuando quieras.';

  @override
  String get settingsExport => 'Exportar datos';

  @override
  String get settingsImport => 'Importar datos';

  @override
  String settingsLastExport(String date) {
    return 'Última exportación: $date';
  }

  @override
  String get settingsNeverExported => 'Nunca exportado';

  @override
  String settingsDbSize(String size) {
    return 'Tamaño de los datos: $size';
  }

  @override
  String get settingsSizeWarning =>
      'La copia automática está cerca de su límite. Exporta tus datos con regularidad.';

  @override
  String get settingsImportTitle => '¿Importar datos?';

  @override
  String get settingsImportBody =>
      'Todos los datos actuales se sustituirán por la copia de seguridad.';

  @override
  String get settingsImportDone => 'Importación completada';

  @override
  String get settingsImportFailed => 'No se pudo leer el archivo.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutBody =>
      'Los datos e imágenes de los productos proceden de Open Food Facts (ODbL).';

  @override
  String get backupShareText => 'Copia de seguridad de TopFlop';

  @override
  String get homeAllProducts => 'Todos los productos';

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterReset => 'Restablecer';

  @override
  String get filterRemove => 'Quitar filtro';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar $count productos',
      one: 'Mostrar 1 producto',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String get filterNoMatchBody => 'Ningún producto coincide con tus filtros.';

  @override
  String get sortTitle => 'Ordenar por';

  @override
  String get sortRecent => 'Valorados recientemente';

  @override
  String get sortBest => 'Tops primero';

  @override
  String get sortWorst => 'Flops primero';

  @override
  String get sortName => 'Nombre A–Z';

  @override
  String get filterScore => 'Valoración';

  @override
  String get filterAny => 'Da igual';

  @override
  String get filterFavoritesOnly => 'Solo favoritos';

  @override
  String get filterStores => 'Tiendas';

  @override
  String get filterCategories => 'Categorías';

  @override
  String filterCategoriesCount(int count) {
    return '$count categorías';
  }

  @override
  String get productEditTitle => 'Editar producto';

  @override
  String get categoryChoose => 'Elegir categoría';

  @override
  String get change => 'Cambiar';

  @override
  String get storeFormNameHint => 'p. ej. Mercadona';

  @override
  String storeFormExists(String name) {
    return '$name ya existe y se seleccionará';
  }

  @override
  String get ratingChange => 'Cambiar valoración';

  @override
  String get productScore => 'Valoración';

  @override
  String productRatedOn(String date) {
    return 'Valorado el $date';
  }

  @override
  String get productYourNote => 'Tu nota';

  @override
  String get ratingWhereHint => 'Elige tantas tiendas como quieras';

  @override
  String get ratingEditTitle => 'Editar valoración';

  @override
  String get storeEditTitle => 'Editar tienda';

  @override
  String get deleteStoreTitle => '¿Eliminar tienda?';

  @override
  String get deleteStoreBody =>
      'Se eliminará la tienda. Tus valoraciones se conservan.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';
}
