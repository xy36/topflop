import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/product_item.dart';
import '../models/product_type.dart';
import '../providers/food_provider.dart';

class AddFoodScreen extends StatefulWidget {
  final String barcode;
  final String? initialName;
  final String? initialBrand;
  final String? initialImageUrl;
  final String? initialCategory;
  final String? initialIngredients;
  final ProductType? initialProductType;
  final ProductItem? existingItem;

  const AddFoodScreen({
    super.key,
    required this.barcode,
    this.initialName,
    this.initialBrand,
    this.initialImageUrl,
    this.initialCategory,
    this.initialIngredients,
    this.initialProductType,
    this.existingItem,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _storeController;
  late TextEditingController _notesController;
  late TextEditingController _ingredientsController;
  late TextEditingController _priceController;
  int _rating = 5;
  bool _isSaving = false;
  String? _localImagePath;
  late ProductType _productType;
  String? _selectedCategory;
  bool _hasChanges = false;

  // Initialwerte für Änderungserkennung
  late String _initialBarcode;
  late String _initialName;
  late String _initialBrand;
  late String _initialStore;
  late String _initialNotes;
  late String _initialIngredients;
  late String _initialPrice;
  late int _initialRating;
  late ProductType _initialProductType;
  String? _initialCategory;
  String? _initialLocalImagePath;

  static const List<String> _defaultStores = [
    'REWE',
    'EDEKA',
    'Aldi',
    'Lidl',
    'Kaufland',
    'Netto',
    'Penny',
    'dm',
    'Rossmann',
    'Müller',
  ];

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(
      text: widget.existingItem?.barcode ?? widget.barcode,
    );
    _nameController = TextEditingController(
      text: widget.existingItem?.name ?? widget.initialName ?? '',
    );
    _brandController = TextEditingController(
      text: widget.existingItem?.brand ?? widget.initialBrand ?? '',
    );
    _storeController = TextEditingController(
      text: widget.existingItem?.store ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingItem?.notes ?? '',
    );
    _ingredientsController = TextEditingController(
      text: widget.existingItem?.ingredients ?? widget.initialIngredients ?? '',
    );
    _priceController = TextEditingController(
      text: widget.existingItem?.price != null
          ? widget.existingItem!.price!.toStringAsFixed(2)
          : '',
    );
    _rating = widget.existingItem?.rating ?? 5;
    _localImagePath = widget.existingItem?.localImagePath;
    _productType =
        widget.existingItem?.productType ??
        widget.initialProductType ??
        ProductType.food;
    _selectedCategory = widget.existingItem?.category ?? widget.initialCategory;

    // Initialwerte merken
    _initialBarcode = _barcodeController.text;
    _initialName = _nameController.text;
    _initialBrand = _brandController.text;
    _initialStore = _storeController.text;
    _initialNotes = _notesController.text;
    _initialIngredients = _ingredientsController.text;
    _initialPrice = _priceController.text;
    _initialRating = _rating;
    _initialProductType = _productType;
    _initialCategory = _selectedCategory;
    _initialLocalImagePath = _localImagePath;

    // Listener für Textfelder
    for (final c in [
      _barcodeController,
      _nameController,
      _brandController,
      _storeController,
      _notesController,
      _ingredientsController,
      _priceController,
    ]) {
      c.addListener(_checkChanges);
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _storeController.dispose();
    _notesController.dispose();
    _ingredientsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasChanges =
        _barcodeController.text != _initialBarcode ||
        _nameController.text != _initialName ||
        _brandController.text != _initialBrand ||
        _storeController.text != _initialStore ||
        _notesController.text != _initialNotes ||
        _ingredientsController.text != _initialIngredients ||
        _priceController.text != _initialPrice ||
        _rating != _initialRating ||
        _productType != _initialProductType ||
        _selectedCategory != _initialCategory ||
        _localImagePath != _initialLocalImagePath;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  String _getRatingEmoji(int rating) {
    switch (rating) {
      case 1:
        return '🤮';
      case 2:
        return '😖';
      case 3:
        return '😣';
      case 4:
        return '😕';
      case 5:
        return '😐';
      case 6:
        return '🙂';
      case 7:
        return '😊';
      case 8:
        return '😋';
      case 9:
        return '🤩';
      case 10:
        return '😍';
      default:
        return '❓';
    }
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required List<String> options,
    required String label,
    required IconData icon,
    TextCapitalization capitalization = TextCapitalization.sentences,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (value) {
        if (value.text.isEmpty) return options;
        return options.where(
          (o) => o.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
      onSelected: (selection) => controller.text = selection,
      fieldViewBuilder: (context, fieldController, focusNode, _) {
        fieldController.addListener(
          () => controller.text = fieldController.text,
        );
        if (fieldController.text.isEmpty && controller.text.isNotEmpty) {
          fieldController.text = controller.text;
        }
        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
          textCapitalization: capitalization,
        );
      },
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.bottomLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final saved = await File(xFile.path).copy('${dir.path}/$fileName');

    if (_localImagePath != null) {
      final oldFile = File(_localImagePath!);
      if (await oldFile.exists()) await oldFile.delete();
    }

    setState(() => _localImagePath = saved.path);
    _checkChanges();
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Foto aufnehmen'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Aus Galerie wählen'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_localImagePath != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Foto entfernen',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final file = File(_localImagePath!);
                      if (await file.exists()) await file.delete();
                      setState(() => _localImagePath = null);
                      _checkChanges();
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<FoodProvider>();
    final item = ProductItem(
      id: widget.existingItem?.id ?? const Uuid().v4(),
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      brand:
          _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
      store:
          _storeController.text.trim().isEmpty
              ? null
              : _storeController.text.trim(),
      rating: _rating,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      imageUrl: widget.existingItem?.imageUrl ?? widget.initialImageUrl,
      createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
      category: _selectedCategory,
      ingredients:
          _ingredientsController.text.trim().isEmpty
              ? null
              : _ingredientsController.text.trim(),
      localImagePath: _localImagePath,
      productType: _productType,
      price: _priceController.text.trim().isEmpty
          ? null
          : double.tryParse(_priceController.text.trim().replaceAll(',', '.')),
    );

    if (widget.existingItem != null) {
      await provider.updateFoodItem(item);
    } else {
      await provider.addFoodItem(item);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Produkt bearbeiten' : 'Neues Produkt'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Produktbild
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: Container(
                height: 160,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      _localImagePath != null
                          ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(_localImagePath!),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: FloatingActionButton.small(
                                  heroTag: 'img_edit',
                                  onPressed: _showImagePickerDialog,
                                  child: const Icon(Icons.edit),
                                ),
                              ),
                            ],
                          )
                          : (widget.initialImageUrl != null ||
                              widget.existingItem?.imageUrl != null)
                          ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                widget.existingItem?.imageUrl ??
                                    widget.initialImageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                      ),
                                    ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: FloatingActionButton.small(
                                  heroTag: 'img_edit',
                                  onPressed: _showImagePickerDialog,
                                  child: const Icon(Icons.add_a_photo),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: scheme.primary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Foto hinzufügen',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: scheme.primary.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),

            // Produkttyp
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategorie',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ProductType.values.map((type) {
                            final selected = _productType == type;
                            return FilterChip(
                              label: Text('${type.icon} ${type.label}'),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _productType = type;
                                  if (!type.subcategories.contains(
                                    _selectedCategory,
                                  )) {
                                    _selectedCategory = null;
                                  }
                                });
                                _checkChanges();
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode (optional)',
                prefixIcon: Icon(Icons.qr_code),
                helperText: 'Kann leer gelassen werden',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Produktname *',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Bitte Produktnamen eingeben'
                          : null,
            ),
            const SizedBox(height: 16),

            _buildAutocompleteField(
              controller: _brandController,
              options: context.read<FoodProvider>().uniqueBrands,
              label: 'Hersteller / Marke',
              icon: Icons.business,
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            _buildAutocompleteField(
              controller: _storeController,
              options:
                  {
                      ...context.read<FoodProvider>().uniqueStores,
                      ..._defaultStores,
                    }.toList()
                    ..sort(),
              label: 'Wo gekauft?',
              icon: Icons.store,
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preis (€)',
                prefixIcon: Icon(Icons.euro),
                hintText: 'z.B. 2,99',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            if (_productType.subcategories.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unterkategorie',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                            _productType.subcategories.map((sub) {
                              final selected = _selectedCategory == sub;
                              return FilterChip(
                                label: Text(sub),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = selected ? null : sub;
                                  });
                                  _checkChanges();
                                },
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Bewertung
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bewertung',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(10, (index) {
                        final r = index + 1;
                        final selected = _rating == r;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _rating = r);
                            _checkChanges();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            transform: Matrix4.translationValues(
                              0,
                              selected ? -8 : 0,
                              0,
                            ),
                            child: AnimatedScale(
                              scale: selected ? 1.5 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: AnimatedOpacity(
                                opacity: selected ? 1.0 : 0.5,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _getRatingEmoji(r),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder:
                            (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                        child: Text(
                          '$_rating / 10',
                          key: ValueKey<int>(_rating),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Zutaten / Inhaltsstoffe',
                prefixIcon: Icon(Icons.list_alt),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notizen',
                prefixIcon: Icon(Icons.note),
                hintText: 'z.B. "Sehr lecker mit Milch"',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _hasChanges ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: FloatingActionButton(
          onPressed: _isSaving ? null : _saveItem,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.save),
        ),
      ),
    );
  }
}
