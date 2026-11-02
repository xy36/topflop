import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/product_category.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/category_picker.dart';
import '../../core/widgets/common.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Name, Marke, Menge und Kategorie korrigieren – z. B. wenn Open Food Facts
/// einen unbrauchbaren Namen liefert.
Future<void> showProductEditSheet(BuildContext context, Product product) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _ProductEditSheet(product: product),
);

class _ProductEditSheet extends ConsumerStatefulWidget {
  const _ProductEditSheet({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductEditSheet> createState() => _ProductEditSheetState();
}

class _ProductEditSheetState extends ConsumerState<_ProductEditSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product.name);
  late final _brand = TextEditingController(text: widget.product.brand);
  late final _quantity = TextEditingController(text: widget.product.quantity);
  late ProductCategory _category = ProductCategory.fromName(widget.product.category);

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _quantity.dispose();
    super.dispose();
  }

  String? _trimmed(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await ref
        .read(productRepositoryProvider)
        .updateProduct(
          widget.product.id,
          name: _name.text.trim(),
          brand: _trimmed(_brand),
          quantity: _trimmed(_quantity),
          category: _category,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.paddingOf(context).bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.productEditTitle, style: AppText.display(24)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.productFormName),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.productFormNameRequired : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _brand,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: '${l10n.productFormBrand} ${l10n.optional}'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantity,
                decoration: InputDecoration(labelText: '${l10n.productFormQuantity} ${l10n.optional}'),
              ),
              const SizedBox(height: 20),
              SectionHeader(l10n.productFormCategory),
              const SizedBox(height: 10),
              CategoryGrid(selected: _category, onSelected: (c) => setState(() => _category = c)),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: Text(l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
