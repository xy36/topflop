import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/product_item.dart';
import '../models/product_type.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _db = DatabaseService();

  // ─── Export ───────────────────────────────────────────────────────────────

  /// Erstellt ein ZIP-Archiv mit allen Produkten (JSON) und lokalen Bildern,
  /// öffnet dann das System-Share-Sheet.
  Future<void> exportBackup() async {
    final items = _db.getAllItems();
    final encoder = ZipFileEncoder();

    final tmpDir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final zipPath = '${tmpDir.path}/backup_$timestamp.zip';

    encoder.create(zipPath);

    // JSON mit allen Produkten
    final jsonList = items.map((item) => _itemToJson(item)).toList();
    final jsonBytes = utf8.encode(jsonEncode(jsonList));
    encoder.addArchiveFile(
      ArchiveFile('products.json', jsonBytes.length, jsonBytes),
    );

    // Lokale Bilder
    for (final item in items) {
      if (item.localImagePath != null) {
        final file = File(item.localImagePath!);
        if (await file.exists()) {
          final fileName = 'images/${item.id}_${file.uri.pathSegments.last}';
          encoder.addFile(file, fileName);
        }
      }
    }

    encoder.close();

    await Share.shareXFiles([XFile(zipPath)], subject: 'Backup_$timestamp');
  }

  // ─── Import ───────────────────────────────────────────────────────────────

  /// Lässt den User eine ZIP-Datei auswählen und stellt alle Daten wieder her.
  /// Gibt die Anzahl der wiederhergestellten Produkte zurück, oder null bei Abbruch.
  Future<int?> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return null;

    final zipFile = File(result.files.single.path!);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final docsDir = await getApplicationDocumentsDirectory();

    // JSON lesen
    final jsonEntry = archive.findFile('products.json');
    if (jsonEntry == null)
      throw Exception('Ungültige Backup-Datei: products.json fehlt');

    final jsonList =
        jsonDecode(utf8.decode(jsonEntry.content as List<int>))
            as List<dynamic>;

    // Bilder extrahieren
    final imageMap =
        <String, String>{}; // originalFileName → neuer lokaler Pfad

    for (final file in archive) {
      if (file.name.startsWith('images/')) {
        final fileName = file.name.split('/').last;
        final outPath = '${docsDir.path}/$fileName';
        final outFile = File(outPath);
        await outFile.writeAsBytes(file.content as List<int>);
        imageMap[fileName] = outPath;
      }
    }

    // Produkte wiederherstellen
    int count = 0;
    for (final raw in jsonList) {
      final map = raw as Map<String, dynamic>;

      // Bild-Pfad auf neuen Gerätepfad mappen
      String? localImagePath;
      final originalPath = map['localImagePath'] as String?;
      if (originalPath != null) {
        final fileName = originalPath.split('/').last;
        localImagePath = imageMap[fileName] ?? originalPath;
      }

      final item = _itemFromJson(map, localImagePath: localImagePath);

      // Nur importieren wenn noch nicht vorhanden (anhand ID)
      if (_db.getItem(item.id) == null) {
        await _db.addItem(item);
        count++;
      }
    }

    return count;
  }

  // ─── Serialisierung ───────────────────────────────────────────────────────

  Map<String, dynamic> _itemToJson(ProductItem item) => {
    'id': item.id,
    'barcode': item.barcode,
    'name': item.name,
    'brand': item.brand,
    'store': item.store,
    'rating': item.rating,
    'notes': item.notes,
    'imageUrl': item.imageUrl,
    'createdAt': item.createdAt.toIso8601String(),
    'category': item.category,
    'ingredients': item.ingredients,
    'localImagePath': item.localImagePath,
    'productType': item.productType.name,
    'price': item.price,
  };

  ProductItem _itemFromJson(
    Map<String, dynamic> map, {
    String? localImagePath,
  }) => ProductItem(
    id: map['id'] as String,
    barcode: map['barcode'] as String,
    name: map['name'] as String,
    brand: map['brand'] as String?,
    store: map['store'] as String?,
    rating: map['rating'] as int,
    notes: map['notes'] as String?,
    imageUrl: map['imageUrl'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    category: map['category'] as String?,
    ingredients: map['ingredients'] as String?,
    localImagePath: localImagePath,
    productType: ProductType.values.firstWhere(
      (t) => t.name == map['productType'],
      orElse: () => ProductType.food,
    ),
    price: (map['price'] as num?)?.toDouble(),
  );
}
