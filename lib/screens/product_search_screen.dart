import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_type.dart';
import '../services/open_products_service.dart';
import 'add_food_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final OpenProductsService _service = OpenProductsService();

  ProductType _selectedType = ProductType.food;
  List<OpenProduct> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _search(query),
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _service.searchProducts(query, _selectedType);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          if (results.isEmpty)
            _errorMessage = 'Keine Produkte gefunden für "$query"';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Fehler bei der Suche. Bitte versuche es erneut.';
        });
      }
    }
  }

  void _selectProduct(OpenProduct product) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => AddFoodScreen(
              barcode: product.barcode,
              initialName: product.name,
              initialBrand: product.brand,
              initialImageUrl: product.imageUrl,
              initialCategory: product.category,
              initialIngredients: product.ingredients,
              initialProductType: product.productType,
            ),
      ),
    );
    if (result == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produkt suchen')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Produktname eingeben...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                              _errorMessage = null;
                            });
                          },
                        )
                        : null,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),

          // Datenbank-Auswahl
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  ProductType.values
                      .where((t) => t != ProductType.other)
                      .map(
                        (type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('${type.icon} ${type.label}'),
                            selected: _selectedType == type,
                            onSelected: (_) {
                              setState(() {
                                _selectedType = type;
                                _results = [];
                                _errorMessage = null;
                              });
                              if (_searchController.text.isNotEmpty) {
                                _search(_searchController.text);
                              }
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Suche läuft...'),
                        ],
                      ),
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                    : _results.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.manage_search,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Suche in ${_selectedType.label}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final product = _results[index];
                        return _ProductCard(
                          product: product,
                          onTap: () => _selectProduct(product),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final OpenProduct product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child:
                        product.imageUrl != null
                            ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _placeholder(scheme),
                            )
                            : _placeholder(scheme),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Unbekanntes Produkt',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.brand != null &&
                          product.brand!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          product.brand!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (product.barcode.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 11,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.barcode,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => Container(
    color: scheme.surfaceContainerHighest,
    child: Icon(
      Icons.inventory_2_outlined,
      size: 28,
      color: scheme.onSurface.withValues(alpha: 0.3),
    ),
  );
}
