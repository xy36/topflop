import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_item.dart';
import '../providers/food_provider.dart';
import 'add_food_screen.dart';

class FoodDetailScreen extends StatelessWidget {
  final ProductItem item;

  const FoodDetailScreen({super.key, required this.item});

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d.$m.${date.year} um $h:$min';
  }

  void _editItem(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(barcode: item.barcode, existingItem: item),
      ),
    );
    if (result == true && context.mounted) Navigator.of(context).pop();
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Produkt löschen?'),
        content: Text('Möchtest du "${item.name}" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<FoodProvider>().deleteFoodItem(item.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produktdetails'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editItem(context), tooltip: 'Bearbeiten'),
          IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteItem(context), tooltip: 'Löschen'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — Bild mit Overlays
            if (item.localImagePath != null || item.imageUrl != null)
              GestureDetector(
                onTap: () => _openLightbox(context, item),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'product_image_${item.id}',
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: item.localImagePath != null
                            ? Image.file(File(item.localImagePath!), fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.image_not_supported, size: 48)))
                            : Image.network(item.imageUrl!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.image_not_supported, size: 48))),
                      ),
                    ),
                    // Gradient overlay unten
                    Positioned(
                      left: 0, right: 0, bottom: 0,
                      height: 80,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                          ),
                        ),
                      ),
                    ),
                    // Badge + Rating auf dem Bild
                    Positioned(
                      left: 16, right: 16, bottom: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${item.productType.icon} ${item.productType.label}',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${item.ratingEmoji} ${item.rating}/10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Fallback ohne Bild: Badge + Rating nebeneinander
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.productType.icon} ${item.productType.label}',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.ratingEmoji} ${item.rating}/10',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // Name + Marke
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (item.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.brand!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Informationen'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _infoTile(context, Icons.qr_code, 'Barcode', item.barcode),
                        if (item.store != null)
                          _infoTile(context, Icons.store, 'Gekauft bei', item.store!),
                        if (item.category != null)
                          _infoTile(context, Icons.category, 'Unterkategorie', item.category!),
                        if (item.price != null)
                          _infoTile(context, Icons.euro, 'Preis', '${item.price!.toStringAsFixed(2)} €'),
                        _infoTile(context, Icons.calendar_today, 'Hinzugefügt am', _formatDate(item.createdAt)),
                      ],
                    ),
                  ),

                  if (item.ingredients != null && item.ingredients!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'Zutaten / Inhaltsstoffe'),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(item.ingredients!, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                  ],

                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'Notizen'),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.note, color: scheme.primary.withValues(alpha: 0.7)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.notes!, style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context, ProductItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            extendBodyBehindAppBar: true,
            body: Hero(
              tag: 'product_image_${item.id}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: SizedBox.expand(
                  child: item.localImagePath != null
                      ? Image.file(File(item.localImagePath!), fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.white)))
                      : Image.network(item.imageUrl!, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.white))),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      );

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Text(value),
      );
}
